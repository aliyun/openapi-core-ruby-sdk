[English](./README.md) | 简体中文


<p align="center">
<a href=" https://www.alibabacloud.com"><img src="https://aliyunsdk-pages.alicdn.com/icons/Aliyun.svg"></a>
</p>

<h1 align="center">Alibaba Cloud Core SDK for Ruby</h1>

<p align="center">
<a href="https://badge.fury.io/rb/aliyunsdkcore"><img src="https://badge.fury.io/rb/aliyunsdkcore.svg" alt="Gem Version"></a>
<a href="https://travis-ci.org/aliyun/openapi-core-ruby-sdk"><img src="https://travis-ci.org/aliyun/openapi-core-ruby-sdk.svg?branch=master" alt="Build Status"></a>
<a href="https://ci.appveyor.com/project/aliyun/openapi-core-ruby-sdk/branch/master"><img src="https://ci.appveyor.com/api/projects/status/uyepkk5bjbynofvu/branch/master?svg=true" alt="Build status"></a>
<a href="https://codecov.io/gh/aliyun/openapi-core-ruby-sdk"><img src="https://codecov.io/gh/aliyun/openapi-core-ruby-sdk/branch/master/graph/badge.svg" alt="codecov"></a>
</p>


Alibaba Cloud Core SDK for Ruby 支持 Ruby 开发者轻松访问阿里云服务，例如：弹性云主机（ECS）、负载均衡（SLB）、云监控（CloudMonitor）等。 您无需处理API相关业务（如签名和构建请求）即可访问阿里云服务。

本文档介绍如何安装和使用 Alibaba Cloud Core SDK for Ruby。

## 安装

```sh
$ gem install aliyunsdkcore
```

## 使用

RPC 示例；

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

print JSON.parse(response.body)
```


ROA 示例：

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

## 问题
[提交 Issue](https://github.com/aliyun/openapi-core-ruby-sdk/issues/new/choose)，不符合指南的问题可能会立即关闭。


## 发行说明
每个版本的详细更改记录在[发行说明](CHANGELOG.md)中。


## 贡献
提交 Pull Request 之前请阅读[贡献指南](CONTRIBUTING.md)。


## 许可证
[MIT](LICENSE.md)

版权所有 1999-2019 阿里巴巴集团
