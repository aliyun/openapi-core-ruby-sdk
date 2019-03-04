require 'set'
require 'faraday'
require 'active_support/all'

class RPCClient

  attr_accessor :endpoint, :api_version, :access_key_id, :access_key_secret, :security_token, :codes, :opts, :verbose

  def initialize(config, verbose = false)

    validate config

    self.endpoint          = config[:endpoint]
    self.api_version       = config[:api_version]
    self.access_key_id     = config[:access_key_id]
    self.access_key_secret = config[:access_key_secret]
    self.security_token    = config[:security_token]
    self.opts              = config[:opts] || {}
    self.verbose           = verbose.instance_of?(TrueClass) && verbose
    self.codes             = [200, '200', 'OK', 'Success']
    self.codes             = Set.new(codes.push(config[:codes]).flatten!) if config[:codes]
  end

  def request(action:, params: {}, opts: {})
    opts           = self.opts.merge(opts)
    action         = action.upcase_first if opts[:format_action]
    params         = format_params(params) unless opts[:format_params]
    defaults       = default_params
    params         = { Action: action }.merge(defaults).merge(params)
    method         = (opts[:method] || 'GET').upcase
    normalized     = normalize(params)
    canonicalized  = canonicalize(normalized)
    string_to_sign = "#{method}&#{encode('/')}&#{encode(canonicalized)}"
    key            = self.access_key_secret + '&'
    signature      = Base64.encode64(OpenSSL::HMAC.digest('sha1', key, string_to_sign)).strip
    normalized.push(['Signature', encode(signature)])

    uri           = opts[:method] == 'POST' ? '/' : "/?#{canonicalize(normalized)}"
    response      = connection.send(method.downcase, uri) do |request|
      if opts[:method] == 'POST'
        request.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        request.body                    = canonicalize(normalized)
      end
    end
    response_body = JSON.parse(response.body)
    if response_body['Code'] && !self.codes.include?(response_body['Code'])
      raise StandardError, "#{response_body['Message']}, URL: #{uri}"
    end
    response
  end

  private

  def connection(adapter = Faraday.default_adapter)
    Faraday.new(:url => self.endpoint) { |faraday| faraday.adapter adapter }
  end

  def default_params
    default_params = {
      :Format           => 'JSON',
      :SignatureMethod  => 'HMAC-SHA1',
      :SignatureNonce   => SecureRandom.hex(16),
      :SignatureVersion => '1.0',
      :Timestamp        => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :AccessKeyId      => self.access_key_id,
      :Version          => self.api_version,
    }
    default_params.merge!(SecurityToken: self.security_token) if self.security_token
    default_params
  end

  def encode(string)
    CGI.escape string
  end

  def format_params(param_hash)
    param_hash.keys.each { |key| param_hash[key.to_s.upcase_first.to_sym] = param_hash.delete key }
    param_hash
  end

  def replace_repeat_list(target, key, repeat)
    repeat.each_with_index do |item, index|
      if item && item.instance_of?(Hash)
        item.each_key { |k| target["#{key}.#{index.next}.#{k}"] = item[k] }
      else
        target["#{key}.#{index.next}"] = item
      end
    end
    target
  end

  def flat_params(params)
    target = {}
    params.each do |key, value|
      if value.instance_of?(Array)
        replace_repeat_list(target, key, value)
      else
        target[key] = value
      end
    end
    target
  end

  def normalize(params)
    flat_params(params)
      .stringify_keys
      .sort
      .to_h
      .map { |key, value| [encode(key), encode(value)] }
  end

  def canonicalize(normalized)
    normalized.map { |element| "#{element.first}=#{element.last}" }.join('&')
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
end