# frozen_string_literal: true

lib = 'aliyunsdkcore'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = Regexp.last_match(1)

Gem::Specification.new do |s|
  s.name    = lib
  s.version = version
  s.platform           = Gem::Platform::RUBY
  s.authors            = ['Alibaba Cloud SDK']
  s.email              = ['sdk-team@alibabacloud.com']
  s.description        = 'Alibaba Cloud Ruby Core SDK'
  s.homepage           = 'http://www.alibabacloud.com/'
  s.summary            = 'Alibaba Cloud Ruby Core SDK'
  s.rubyforge_project  = 'aliyunsdkcore'
  s.license            = 'MIT'
  s.files              = Dir['{lib}/**/*', 'LICENSE.md', 'README.md', 'README-CN.md', 'CHANGELOG.md']
  s.require_paths      = ['lib']

  s.add_dependency 'activesupport', '>= 4.0.0'
  s.add_dependency 'faraday', '>= 0.15.4'
end
