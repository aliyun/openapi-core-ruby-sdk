require 'rspec'
require 'webmock/rspec'

require "aliyunsdkcore"

describe 'ROAClient' do

  describe 'initialize' do

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
        ROAClient.new(endpoint: 'ros.aliyuncs.com/')
      }.to raise_error(ArgumentError, '"config.endpoint" must starts with \'https://\' or \'http://\'.')
    end

    it 'should pass into "config[:api_version]"' do
      expect {
        ROAClient.new(endpoint: 'http://ros.aliyuncs.com/')
      }.to raise_error(ArgumentError, 'must pass "config[:api_version]"')
    end

    it 'should pass into "config[:access_key_id]"' do
      expect {
        ROAClient.new(endpoint: 'http://ros.aliyuncs.com/', api_version: '1.0')
      }.to raise_error(ArgumentError, 'must pass "config[:access_key_id]"')
    end

    it 'should pass into "config[:access_key_secret]"' do
      expect {
        ROAClient.new(endpoint: 'http://ros.aliyuncs.com/', api_version: '1.0', access_key_id: 'access_key_id')
      }.to raise_error(ArgumentError, 'must pass "config[:access_key_secret]"')
    end

    it 'should ok with http protocol' do
      roa_client = ROAClient.new(
        endpoint:          'http://ros.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret'
      )
      expect(roa_client.endpoint).to eq('http://ros.aliyuncs.com/')
    end

    it 'should ok with https protocol' do
      roa_client = ROAClient.new(
        endpoint:          'https://ros.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret'
      )
      expect(roa_client.endpoint).to eq('https://ros.aliyuncs.com/')
    end

    let(:roa_client) do
      ROAClient.new(
        endpoint:          'https://ros.aliyuncs.com/',
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
          x-sdk-client
          user-agent)
    end

    it 'default headers should ok' do
      expect(roa_client.default_headers.keys).to match_array(default_header_keys)
      expect(roa_client.default_headers['accept']).to eq('application/json')
      expect(roa_client.default_headers['date']).to match(/[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT/)
      expect(roa_client.default_headers['host']).to eq('ros.aliyuncs.com')
      expect(roa_client.default_headers['user-agent']).to match(/AlibabaCloud \(.*; .*\) Ruby\/\d+.\d+.\d+ Core\/\d+.\d+.\d+/)
    end

    it 'default_headers should ok with security_token' do
      roa_client = ROAClient.new(
        endpoint:          'https://ros.aliyuncs.com/',
        api_version:       '1.0',
        access_key_id:     'access_key_id',
        access_key_secret: 'access_key_secret',
        security_token:    'security_token'
      )

      default_header_keys = %w(
        accept
        date
        host
        x-acs-signature-nonce
        x-acs-signature-method
        x-acs-signature-version
        x-acs-version
        x-sdk-client
        x-acs-accesskey-id
        x-acs-security-token
        user-agent
      )

      expect(roa_client.default_headers['accept']).to eq('application/json')
      expect(roa_client.default_headers.keys).to match_array(default_header_keys)
      expect(roa_client.default_headers['date']).to match(/[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT/)
      expect(roa_client.default_headers['accept']).to eq('application/json')
      expect(roa_client.default_headers['user-agent']).to match(/AlibabaCloud \(.*; .*\) Ruby\/\d+.\d+.\d+ Core\/\d+.\d+.\d+/)
    end

    describe 'request with json response should ok' do
      it 'json response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/")
          .to_return(status: 200, headers: { 'Content-Type': 'application/json' }, body: { ok: true }.to_json)
        response = roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        expect(response.body).to eq({ ok: true }.to_json)
      end
    end

    describe 'request(204) with json response should ok' do
      it 'json response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/")
          .to_return(status: 204, headers: { 'Content-Type': 'application/json' }, body: '')
        response = roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        expect(response.body).to eq('')
      end
    end

    describe 'request(400) with json response should ok' do
      let(:status) { 400 }
      let(:headers) { { 'Content-Type': 'application/json' } }
      let(:body) { { 'Message': 'error message', 'RequestId': 'requestid', 'Code': 'errorcode' }.to_json }
      it 'json response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/")
          .to_return(status: status, headers: headers, body: body)
        expect {
          roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        }.to raise_error(StandardError, 'code: 400, error message requestid: requestid')
      end
    end

    describe 'request with xml response should ok' do
      let(:status) { 200 }
      let(:headers) { { 'Content-Type': 'text/xml' } }
      let(:body) do
        <<-XML
          <note>
            <to>George</to>
            <from>John</from>
            <heading>Reminder</heading>
            <body>Don't forget the meeting!</body>
          </note>
        XML
      end
      it 'xml response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/")
          .to_return(status: status, headers: headers, body: body)
        response = roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        expect(response.body).to eq(body)
      end
    end

    describe 'request(400) with xml response should ok' do
      let(:status) { 400 }
      let(:headers) { { 'Content-Type': 'text/xml' } }
      let(:body) do
        <<-XML
          <Error>
            <Message>error message</Message>
            <RequestId>requestid</RequestId>
            <HostId>hostid</HostId>
            <Code>errorcode</Code>
          </Error>
        XML
      end
      it 'xml response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/")
          .to_return(status: status, headers: headers, body: body)
        expect {
          roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        }.to raise_error(ROAClient::ACSError, 'error message host_id: hostid, request_id: requestid')
      end
    end

    describe 'request(200) with plain response should ok' do
      it 'plain response should ok' do
        stub_request(:get, "https://ros.aliyuncs.com/").to_return(status: 200, body: 'plain text')
        response = roa_client.get(uri: '/', headers: { 'content-type': 'application/json' })
        expect(response.body).to eq('plain text')
      end
    end

    describe 'post should ok' do
      it 'should ok' do
        stub_request(:post, "https://ros.aliyuncs.com/")
          .to_return(status: 200, headers: { 'content-type': 'application/json' }, body: { ok: true }.to_json)
        response = roa_client.post(uri: '/', headers: { 'content-type': 'application/json' }, body: 'text')
        expect(response.body).to eq('{"ok":true}')
      end
      it 'should ok with query' do
        stub_request(:post, "https://ros.aliyuncs.com/?k=v")
          .to_return(status: 200, headers: { 'content-type': 'application/json' }, body: { ok: true }.to_json)
        response = roa_client.post(uri: '/', headers: { 'content-type': 'application/json' }, params: { k: 'v' }, body: 'text')
        expect(response.body).to eq('{"ok":true}')
      end
    end

    describe 'put should ok' do
      it 'should ok' do
        stub_request(:put, "https://ros.aliyuncs.com/")
          .to_return(status: 200, headers: { 'content-type': 'application/json' }, body: { ok: true }.to_json)
        response = roa_client.put(uri: '/', headers: { 'content-type': 'application/json' }, body: 'text')
        expect(response.body).to eq('{"ok":true}')
      end
    end

    describe 'delete should ok' do
      it 'should ok' do
        stub_request(:delete, "https://ros.aliyuncs.com/")
          .to_return(status: 200, headers: { 'content-type': 'application/json' }, body: { ok: true }.to_json)
        response = roa_client.delete(uri: '/', headers: { 'content-type': 'application/json' })
        expect(response.body).to eq('{"ok":true}')
      end
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
        roa_client.send(:string_to_sign, 'GET', '/', { 'accept' => 'application/json' })
      ).to eq("GET\napplication/json\n\n\n\n/")
    end

    describe 'ROAClient::ACSError class' do
      it 'ACSError should ok' do
        expect {
          error_info = {
            'Message' =>   'error message',
            'Code' =>      'errorcode',
            'HostId' =>    'hostid',
            'RequestId' => 'requestid',
          }
          raise ROAClient::ACSError, error_info
        }.to raise_error(ROAClient::ACSError, 'error message host_id: hostid, request_id: requestid')
      end
    end

  end
end
