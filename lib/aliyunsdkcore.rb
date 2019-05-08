require 'aliyunsdkcore/rpc_client'
require 'aliyunsdkcore/roa_client'

module AliyunSDKCore
  VERSION = "0.0.7"
  DEFAULT_UA = "AlibabaCloud (#{Gem::Platform.local.os}; " +
    "#{Gem::Platform.local.cpu}) Ruby/#{RUBY_VERSION} Core/#{VERSION}"
end

RPCClient = AliyunSDKCore::RPCClient
ROAClient = AliyunSDKCore::ROAClient
