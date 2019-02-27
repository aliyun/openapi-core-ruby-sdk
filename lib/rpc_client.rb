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

  private

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