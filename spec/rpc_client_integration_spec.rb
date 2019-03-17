require 'rspec'
require 'rpc_client'
require 'webmock/rspec'

describe 'rpc request' do

  WebMock.disable_net_connect!(allow: %r{ecs.aliyuncs.com})

  let(:rpc_client) do
    RPCClient.new(
      endpoint:          'https://ecs.aliyuncs.com',
      api_version:       '2014-05-26',
      access_key_id:     ENV['ACCESS_KEY_ID'],
      access_key_secret: ENV['ACCESS_KEY_SECRET'],
    )
  end

  it 'should ok' do
    params         = { key: (1..11).to_a.map(&:to_s) }
    request_option = { method: 'POST', timeout: 15000 }
    response       = rpc_client.request(action: 'DescribeRegions', params: params, opts: request_option)
    response_body  = JSON.parse(response.body)
    expect(response_body.keys.include?('Regions')).to be true
    expect(response_body.keys.include?('RequestId')).to be true
  end

  it 'should ok with repeat list less 10 item' do
    params         = { key: (1..9).to_a.map(&:to_s) }
    request_option = { method: 'POST', timeout: 15000 }
    response       = rpc_client.request(action: 'DescribeRegions', params: params, opts: request_option)
    response_body  = JSON.parse(response.body)
    expect(response_body.keys.include?('Regions')).to be true
    expect(response_body.keys.include?('RequestId')).to be true
  end
end