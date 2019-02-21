require 'faraday'
require 'securerandom'
require 'active_support/all'

class ROAClient

  # FIXME: 如何设置 keep_alive_timeout
  attr_accessor :headers
  attr_accessor :endpoint, :api_version, :access_key_id, :access_key_secret, :security_token, :hostname, :opts

  METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE]

  def initialize(config)

    validate config

    self.endpoint          = config[:endpoint]
    self.api_version       = config[:api_version]
    self.access_key_id     = config[:access_key_id]
    self.access_key_secret = config[:access_key_secret]

    self.headers = default_headers

  end

  def request(method:, uri:, params: {}, body: {}, headers: {}, options: {})

    mix_headers = default_headers.merge(headers).symbolize_keys!

    response = connection.send(method.downcase) do |request|
      request.url uri, params
      request.body = body.to_json unless body.nil? || body.empty?
      mix_headers.each { |key, value| request.headers[key] = value }
    end

    return response if options.has_key? :raw_body

    response_content_type = response.headers['Content-Type'] || ''
    if response_content_type.start_with?('application/json')
      if response.status >= 400
        result = JSON.parse(response.body)
        raise StandardError, "code: #{response.status}, #{result['Message']} requestid: #{result['RequestId']}"
      end
    end

    if response_content_type.start_with?('text/xml')
      result = Hash.from_xml(response.body)
      raise ACSError, result['Error'] if result['Error']
    end

    response
  end

  def connection(adapter = Faraday.default_adapter)
    Faraday.new(:url => self.endpoint) { |faraday| faraday.adapter adapter }
  end

  def get(uri: '', headers: {}, params: {}, options: {})
    request(method: :get, uri: uri, params: params, body: {}, headers: headers, options: options)
  end

  def post(uri: '', headers: {}, params: {}, body: {}, options: {})
    request(method: :get, uri: uri, params: params, body: body, headers: headers, options: options)
  end

  def put(uri: '', headers: {}, params: {}, body: {}, options: {})
    request(method: :get, uri: uri, params: params, body: body, headers: headers, options: options)
  end

  def delete(uri: '', headers: {}, params: {}, options: {})
    request(method: :get, uri: uri, params: params, body: {}, headers: headers, options: options)
  end

  private

  def string_to_sign(method, uri, headers, query = {})
    header_string = [
      method,
      headers[:accept],
      headers['content-md5'] || '',
      headers['content-type'] || '',
      headers['date'],
    ].join("\n")
    "#{header_string}\n#{canonicalized_headers(headers)}#{canonicalized_resource(uri, query)}"
  end

  def canonicalized_headers(headers)
    headers.keys.select { |key| key.to_s.start_with? 'x-acs-' }
      .sort.map { |key| "#{key}:#{headers[key].strip}\n" }.join
  end

  def canonicalized_resource(uri, query_hash = {})
    query_string = query_hash.map { |key, value| "#{key}=#{value}" }.join('&')
    query_string.empty? ? uri : "#{uri}?#{query_string}"
  end

  def authorization(string_to_sign)
    "acs #{self.access_key_id}:#{signature(string_to_sign)}"
  end

  def signature(string_to_sign)
    Base64.encode64(OpenSSL::HMAC.digest('sha1', self.access_key_secret, string_to_sign)).strip
  end

  def validate(config)
    raise ArgumentError, 'must pass "config"' unless config
    raise ArgumentError, 'must pass "config[:endpoint]"' unless config[:endpoint]
    unless config[:endpoint].start_with?('http://') || config[:endpoint].start_with?('https://')
      raise ArgumentError, '"config.endpoint" must starts with \'https://\' or \'http://\'.'
    end
    raise ArgumentError, 'must pass "config[:api_version]"' unless config[:api_version]
    raise ArgumentError, 'must pass "config[:access_key_id]"' unless config[:access_key_id]
    raise ArgumentError, 'must pass "config[:access_key_secret]"' unless config[:access_key_secret]
  end

  def default_headers
    default_headers = {
      'accept':                  'application/json',
      'date':                    Time.now.httpdate,
      'host':                    URI(self.endpoint).host,
      'x-acs-signature-nonce':   SecureRandom.hex(16),
      'x-acs-signature-method':  'HMAC-SHA1',
      'x-acs-signature-version': '1.0',
      'x-acs-version':           self.api_version,
      'x-sdk-client':            "RUBY(#{RUBY_VERSION})" # FIXME: 如何获取Gem的名称和版本号
    }
    if self.security_token
      default_headers.merge!('x-acs-accesskey-id': self.access_key_id, 'x-acs-security-token': self.security_token)
    end
    default_headers
  end

  class ACSError < StandardError

    attr_accessor :code

    def initialize(error)
      self.code    = error['Code']
      message      = error['Message']
      host_id      = error['HostId']
      request_id   = error['RequestId']
      super("#{message} host_id: #{host_id}, request_id: #{request_id}")
    end

  end

end