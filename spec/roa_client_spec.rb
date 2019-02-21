require 'rspec'
require 'roa_client'

describe 'roa core' do

  it 'should pass into "config"' do
    expect {
      ROAClient.new(nil)
    }.to raise_error(ArgumentError, 'must pass "config"')
  end

  it 'should pass into "config[:endpoint]"' do
    expect {
      ROAClient.new({})
    }.to raise_error(ArgumentError, 'must pass "config[:endpoint]"')
  end

  it 'should pass into valid "config[:endpoint]"' do
    expect {
      ROAClient.new(endpoint: 'ecs.aliyuncs.com/')
    }.to raise_error(ArgumentError, '"config.endpoint" must starts with \'https://\' or \'http://\'.')
  end

  it 'should pass into "config[:api_version]"' do
    expect {
      ROAClient.new(endpoint: 'http://ecs.aliyuncs.com/')
    }.to raise_error(ArgumentError, 'must pass "config[:api_version]"')
  end

  it 'should pass into "config[:access_key_id]"' do
    expect {
      ROAClient.new(endpoint: 'http://ecs.aliyuncs.com/', api_version: '1.0')
    }.to raise_error(ArgumentError, 'must pass "config[:access_key_id]"')
  end

  it 'should pass into "config[:access_key_secret]"' do
    expect {
      ROAClient.new(endpoint: 'http://ecs.aliyuncs.com/', api_version: '1.0', access_key_id: 'access_key_id')
    }.to raise_error(ArgumentError, 'must pass "config[:access_key_secret]"')
  end

  it 'should ok with http protocol' do
    roa_client = ROAClient.new(
      endpoint:          'http://ecs.aliyuncs.com/',
      api_version:       '1.0',
      access_key_id:     'access_key_id',
      access_key_secret: 'access_key_secret'
    )
    expect(roa_client.endpoint).to eq('http://ecs.aliyuncs.com/')
  end

  it 'should ok with https protocol' do
    roa_client = ROAClient.new(
      endpoint:          'https://ecs.aliyuncs.com/',
      api_version:       '1.0',
      access_key_id:     'access_key_id',
      access_key_secret: 'access_key_secret'
    )
    expect(roa_client.endpoint).to eq('https://ecs.aliyuncs.com/')
  end

  let(:roa_client) do
    ROAClient.new(
      endpoint:          'https://ecs.aliyuncs.com/',
      api_version:       '1.0',
      access_key_id:     'access_key_id',
      access_key_secret: 'access_key_secret'
    )
  end

  let(:default_header_keys) do
    %w(accept date host
        x-acs-signature-nonce
        x-acs-signature-method
        x-acs-signature-version
        x-acs-version
        x-sdk-client).map(&:to_sym)
  end

  it 'default headers should ok' do
    expect(roa_client.headers.keys).to match_array(default_header_keys)
    expect(roa_client.headers[:accept]).to eq('application/json')
    expect(roa_client.headers[:date]).to match(/[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT/)
    expect(roa_client.headers[:host]).to eq('ecs.aliyuncs.com')
  end

  it 'signature should ok' do
    expect(roa_client.send(:signature, '123456')).to eq('BeAYlq/e5iWAoTNmzf8jbcBxdq0=')
  end

  it 'authorization should ok' do
    expect(roa_client.send(:authorization, '123456')).to eq('acs access_key_id:BeAYlq/e5iWAoTNmzf8jbcBxdq0=')
  end

  it 'canonicalized_headers should ok' do
    expect(roa_client.send(:canonicalized_headers, {})).to be_empty
    expect(roa_client.send(:canonicalized_headers, { key: 'value' })).to be_empty
    expect(roa_client.send(:canonicalized_headers, { 'x-acs-key': 'value' })).to eq("x-acs-key:value\n")
  end

  it 'canonicalized_resource should ok' do
    expect(roa_client.send(:canonicalized_resource, '/')).to eq('/')
    expect(roa_client.send(:canonicalized_resource, '/', { key: 'value' })).to eq('/?key=value')
    expect(roa_client.send(:canonicalized_resource, '/', { key: 'value', 'key1': 'value2' })).to eq('/?key=value&key1=value2')
  end

  it 'string_to_sign should ok ' do
    expect(
      roa_client.send(:string_to_sign, 'GET', '/', { accept: 'application/json' })
    ).to eq("GET\napplication/json\n\n\n\n/")
  end


end