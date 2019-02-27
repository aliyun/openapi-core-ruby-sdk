require 'rspec'
require 'rpc_client'
require 'webmock/rspec'

describe 'rpc core' do

  describe 'RPCClient' do
    it 'should pass into "config"' do
      expect {
        RPCClient.new(nil)
      }.to raise_error(ArgumentError, 'must pass "config"')
    end

    it 'should pass into "config[:endpoint]"' do
      expect {
        RPCClient.new({})
      }.to raise_error(ArgumentError, 'must pass "config[:endpoint]"')
    end

    it 'should pass into valid "config[:endpoint]"' do
      expect {
        RPCClient.new(endpoint: 'ecs.aliyuncs.com/')
      }.to raise_error(ArgumentError, '"config.endpoint" must starts with \'https://\' or \'http://\'.')
    end

    it 'should pass into "config[:api_version]"' do
      expect {
        RPCClient.new(endpoint: 'http://ecs.aliyuncs.com/')
      }.to raise_error(ArgumentError, 'must pass "config[:api_version]"')
    end

    it 'should pass into "config[:access_key_id]"' do
      expect {
        RPCClient.new(endpoint: 'http://ecs.aliyuncs.com/', api_version: '1.0')
      }.to raise_error(ArgumentError, 'must pass "config[:access_key_id]"')
    end

    it 'should pass into "config[:access_key_secret]"' do
      expect {
        RPCClient.new(endpoint: 'http://ecs.aliyuncs.com/', api_version: '1.0', access_key_id: 'access_key_id')
      }.to raise_error(ArgumentError, 'must pass "config[:access_key_secret]"')
    end

    it 'should ok with http protocol' do
      rpc_client = RPCClient.new(
        endpoint:          'http://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret'
      )
      expect(rpc_client.endpoint).to eq('http://ecs.aliyuncs.com/')
    end

    it 'should ok with https protocol' do
      rpc_client = RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret'
      )
      expect(rpc_client.endpoint).to eq('https://ecs.aliyuncs.com/')
    end

    it 'should ok with codes' do
      rpc_client = RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
        codes:             ['True']
      )
      expect(rpc_client.codes).to match_array ['True']
    end
  end

end