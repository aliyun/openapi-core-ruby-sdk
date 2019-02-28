require 'active_support/all'

class RPCClient

  attr_accessor :endpoint, :api_version, :access_key_id, :access_key_secret, :security_token, :hostname, :codes, :opts

  def initialize(config)

    validate config

    self.endpoint          = config[:endpoint]
    self.api_version       = config[:api_version]
    self.access_key_id     = config[:access_key_id]
    self.access_key_secret = config[:access_key_secret]
    self.security_token    = config[:security_token]
    self.codes             = config[:codes]

  end

  def default_params
    default_params = {
      :Format           => 'JSON',
      :SignatureMethod  => 'HMAC-SHA1',
      :SignatureNonce   => SecureRandom.hex(16),
      :SignatureVersion => '1.0',
      :Timestamp        => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :AccessKeyId      => self.access_key_id,
      :Version          => self.api_version,
    }
    default_params.merge!(SecurityToken: self.security_token) if self.security_token
    default_params
  end

  private

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
    URI.encode_www_form normalized
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