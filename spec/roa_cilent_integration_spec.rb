require 'rspec'
require 'roa_client'
require 'webmock/rspec'

describe 'roa request' do

  WebMock.disable_net_connect!(allow: %r{ros.aliyuncs.com/regions})

  let(:roa_client) do
    ROAClient.new(
      endpoint:          'http://ros.aliyuncs.com',
      api_version:       '2015-09-01',
      access_key_id:     ENV['ACCESS_KEY_ID'],
      access_key_secret: ENV['ACCESS_KEY_SECRET'],
      )
  end

  it 'request' do
    sleep 10
    response = roa_client.request(method: 'GET', uri: '/regions', options: { timeout: 15000 })
    expect(JSON.parse(response.body).keys.include?('Regions')).to be true
  end

  it 'get should ok' do
    sleep 10
    response = roa_client.request(method: 'GET', uri: '/regions', options: { timeout: 10000 })
    expect(JSON.parse(response.body).keys.include?('Regions')).to be true
  end

  it 'get raw body should ok' do
    sleep 10
    options  = { raw_body: true, timeout: 10000 }
    response = roa_client.request(method: 'GET', uri: '/regions', options: options)
    expect(response.body.instance_of? String).to be true
  end

end