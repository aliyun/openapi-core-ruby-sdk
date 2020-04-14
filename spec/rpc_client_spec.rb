require 'rspec'
require 'webmock/rspec'

require "aliyunsdkcore"

describe 'RPCClient' do

  describe 'initialize' do
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
      expect(rpc_client.codes.include? 'True').to be true
    end
  end

  describe 'default params' do

    it 'should ok' do
      rpc_client          = RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
      )
      default_params_keys = %w(Format SignatureMethod SignatureNonce SignatureVersion Timestamp AccessKeyId Version)
      expect(rpc_client.send(:default_params).keys).to match_array default_params_keys
    end
  end

  it 'should ok with securityToken' do
    rpc_client          = RPCClient.new(
      endpoint:          'https://ecs.aliyuncs.com/',
      api_version:       '1.0',
      access_key_id:     'access_key_id',
      access_key_secret: 'access_key_secret',
      security_token:    'security_token'
    )
    default_params_keys = %w(Format SignatureMethod SignatureNonce SignatureVersion Timestamp AccessKeyId Version SecurityToken)
    expect(rpc_client.send(:default_params).keys).to match_array default_params_keys
  end

  describe 'request' do
    it 'get with raw body should ok' do
      rpc_client = RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
      )
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 200, body: {}.to_json)
      expect(rpc_client.request(action: 'action')).to eql({})
    end
  end

  describe 'request with post' do

    let(:rpc_client) do
      RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
        security_token:    'security_token'
      )
    end

    it 'should ok' do
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 200, body: {}.to_json)
      expect(rpc_client.request(action: 'action')).to eql({})
    end

    it 'should ok with format_action' do
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 200, body: {}.to_json)
      response = rpc_client.request(action: 'action', opts: { format_action: false })
      expect(response).to eql({})
    end

    it 'should ok with format_params' do
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 200, body: {}.to_json)
      response = rpc_client.request(action: 'action', opts: { format_params: false })
      expect(response).to eql({})
    end

    it 'get with raw body should ok' do
      stub_request(:post, "https://ecs.aliyuncs.com").to_return(status: 200, body: {}.to_json)
      response = rpc_client.request(action: 'action', opts: { method: 'POST' })
      expect(response).to eql({})
    end
  end

  describe 'request with error' do

    let(:rpc_client) do
      RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
      )
    end

    it 'request with 400 should ok' do
      mock_response = { Code: 400, Message: 'error message' }.to_json
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 400, body: mock_response)
      expect {
        rpc_client.request(action: 'action')
      }.to raise_error(StandardError, /error message, URL:/)
    end

    it 'request with no problem should be ok' do
      mock_response = { Code: "" }.to_json
      stub_request(:get, /https:\/\/ecs.aliyuncs.com/).to_return(status: 200, body: mock_response)
      expect {
        rpc_client.request(action: 'action')
      }.to_not raise_error(StandardError)
    end
  end

  describe 'RPC private methods' do

    let(:rpc_client) do
      RPCClient.new(
        endpoint:          'https://ecs.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
        security_token:    'security_token'
      )
    end

    it 'formatParams should ok' do
      expect(rpc_client.send(:format_params, { foo: 1, bar: 2 })).to eq(Foo: 1, Bar: 2)
    end

    it 'encode should ok' do
      expect(rpc_client.send(:encode, 'str')).to eq 'str'
      expect(rpc_client.send(:encode, 'str\'str')).to eq 'str%27str'
      expect(rpc_client.send(:encode, 'str(str')).to eq 'str%28str'
      expect(rpc_client.send(:encode, 'str)str')).to eq 'str%29str'
      expect(rpc_client.send(:encode, 'str*str')).to eq 'str%2Astr'
    end

    it 'replace_repeat_list should ok' do
      expect(rpc_client.send(:replace_repeat_list, {}, 'key', [])).to eq({})
      expect(rpc_client.send(:replace_repeat_list, {}, 'key', ['value'])).to eq({ 'key.1' => 'value' })
      expect(rpc_client.send(:replace_repeat_list, {}, 'key', [{ :Domain => '1.com' }])).to eq({ 'key.1.Domain' => '1.com' })
    end

    it 'flat_params should ok' do
      expect(rpc_client.send(:flat_params, {})).to eq({})
      expect(rpc_client.send(:flat_params, { key: ['value'] })).to eq({ 'key.1' => 'value' })
      expect(rpc_client.send(:flat_params, { key: 'value' })).to eq({ 'key' => 'value' })
      expect(rpc_client.send(:flat_params, { key: [{ Domain: '1.com' }] })).to eq({ 'key.1.Domain' => '1.com' })
    end

    it 'normalize should ok' do
      expect(rpc_client.send(:normalize, {})).to be_empty
      expect(rpc_client.send(:normalize, { key: ['value'] })).to match_array [%w(key.1 value)]
      expect(rpc_client.send(:normalize, { key: 'value' })).to match_array [%w(key value)]
      expect(rpc_client.send(:normalize, { key: [{ Domain: '1.com' }] })).to match_array [%w(key.1.Domain 1.com)]
      expect(rpc_client.send(:normalize, { a: 'value', c: 'value', b: 'value' }))
        .to match_array [%w(a value), %w(b value), %w(c value)]
    end

    it 'canonicalize should ok' do
      expect(rpc_client.send(:canonicalize, [])).to be_empty
      expect(rpc_client.send(:canonicalize, { foo: 1 })).to eq 'foo=1'
      expect(rpc_client.send(:canonicalize, [['foo', 1]])).to eq 'foo=1'
      expect(rpc_client.send(:canonicalize, { foo: 1, bar: 2 })).to eq 'foo=1&bar=2'
      expect(rpc_client.send(:canonicalize, [['foo', 1], ['bar', 2]])).to eq 'foo=1&bar=2'
    end
  end

end
