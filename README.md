# Alibaba Cloud Ruby Software Development Kit(Working in progress)

[![Gem Version](https://badge.fury.io/rb/aliyunsdkcore.svg)](https://badge.fury.io/rb/aliyunsdkcore)
[![Build Status](https://travis-ci.org/aliyun/openapi-core-ruby-sdk.svg?branch=master)](https://travis-ci.org/aliyun/openapi-core-ruby-sdk)
[![Build status](https://ci.appveyor.com/api/projects/status/uyepkk5bjbynofvu/branch/master?svg=true)](https://ci.appveyor.com/project/aliyun/openapi-core-ruby-sdk/branch/master)
[![codecov](https://codecov.io/gh/aliyun/openapi-core-ruby-sdk/branch/master/graph/badge.svg)](https://codecov.io/gh/aliyun/openapi-core-ruby-sdk)

The Alibaba Cloud Ruby Software Development Kit (SDK) allows you to access Alibaba Cloud services such as Elastic Compute Service (ECS), Server Load Balancer (SLB), and CloudMonitor. You can access Alibaba Cloud services without the need to handle API related tasks, such as signing and constructing your requests.

This document introduces how to install and use Alibaba Cloud Ruby SDK.

If you have any problem while using Ruby SDK, please submit an issue.

## Installation

```sh
$ gem install aliyunsdkcore
```

## Usage

The RPC demo:

```ruby
require 'aliyunsdkcore'

client = RPCClient.new(
  endpoint:          'http://ros.aliyuncs.com',
  api_version:       '2015-09-01',
  access_key_id:     ENV['ACCESS_KEY_ID'],
  access_key_secret: ENV['ACCESS_KEY_SECRET'],
)

params         = { key: (1..11).to_a.map(&:to_s) }
request_option = { method: 'POST', timeout: 15000 }
response       = client.request(
  action: 'DescribeRegions',
  params: params,
  opts: request_option
)

print JSON.parse(response.body)
```


The ROA demo:

```ruby
require 'aliyunsdkcore'

client = ROAClient.new(
  endpoint:          'http://ros.aliyuncs.com',
  api_version:       '2015-09-01',
  access_key_id:     ENV['ACCESS_KEY_ID'],
  access_key_secret: ENV['ACCESS_KEY_SECRET'],
)

response = client.request(
  method: 'GET',
  uri: '/regions',
  options: {
    timeout: 15000
  }
)

print JSON.parse(response.body)
```

## License
