English | [简体中文](./README-CN.md)


<p align="center">
<a href=" https://www.alibabacloud.com"><img src="https://aliyunsdk-pages.alicdn.com/icons/AlibabaCloud.svg"></a>
</p>

<h1 align="center">Alibaba Cloud Core SDK for Ruby</h1>

<p align="center">
<a href="https://badge.fury.io/rb/aliyunsdkcore"><img src="https://badge.fury.io/rb/aliyunsdkcore.svg" alt="Gem Version"></a>
<a href="https://travis-ci.org/aliyun/openapi-core-ruby-sdk"><img src="https://travis-ci.org/aliyun/openapi-core-ruby-sdk.svg?branch=master" alt="Build Status"></a>
<a href="https://ci.appveyor.com/project/aliyun/openapi-core-ruby-sdk/branch/master"><img src="https://ci.appveyor.com/api/projects/status/uyepkk5bjbynofvu/branch/master?svg=true" alt="Build status"></a>
<a href="https://codecov.io/gh/aliyun/openapi-core-ruby-sdk"><img src="https://codecov.io/gh/aliyun/openapi-core-ruby-sdk/branch/master/graph/badge.svg" alt="codecov"></a>
</p>


Alibaba Cloud Core SDK for Ruby allows you to access Alibaba Cloud services such as Elastic Compute Service (ECS), Server Load Balancer (SLB), and CloudMonitor. You can access Alibaba Cloud services without the need to handle API related tasks, such as signing and constructing your requests.

This document introduces how to install and use Alibaba Cloud Core SDK for Ruby.

## Troubleshoot
[Troubleshoot](https://troubleshoot.api.aliyun.com/?source=github_sdk) Provide OpenAPI diagnosis service to help developers locate quickly and provide solutions for developers through `RequestID` or `error message`.

## Installation

```sh
$ gem install aliyunsdkcore
```

## Usage

The RPC demo:

```ruby
require 'aliyunsdkcore'

client = RPCClient.new(
  endpoint:          'https://ecs.aliyuncs.com',
  api_version:       '2014-05-26',
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

print response
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

print response.body
```

## Issues
[Opening an Issue](https://github.com/aliyun/openapi-core-ruby-sdk/issues/new/choose), Issues not conforming to the guidelines may be closed immediately.


## Changelog
Detailed changes for each release are documented in the [release notes](CHANGELOG.md).


## Contribution
Please make sure to read the [Contributing Guide](CONTRIBUTING.md) before making a pull request.


## License
[MIT](LICENSE.md)

Copyright 1999-2019 Alibaba Group Holding Ltd.
