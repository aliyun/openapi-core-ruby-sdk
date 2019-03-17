# encoding: utf-8

lib = 'aliyunsdkcore'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = Regexp.last_match(1)

Gem::Specification.new do |s|
  s.name    = lib
  s.version = version
  s.platform           = Gem::Platform::RUBY
  s.authors            = ["Alibaba Cloud SDK"]
  s.email              = ["sdk-team@alibabacloud.com"]
  s.description        = %q{Alibaba Cloud Ruby Core SDK}
  s.homepage           = %q{http://www.alibabacloud.com/}
  s.summary            = %q{Alibaba Cloud Ruby Core SDK}
  s.rubyforge_project  = "aliyunsdkcore"
  s.license            = "MIT"
  s.files              = `git ls-files -z lib`.split("\0")
  s.files              += %w[README.md]
  s.test_files         = `git ls-files -z spec`.split("\0")
  s.require_paths      = ["lib"]

  s.add_dependency 'faraday', '~> 0.15.4'
  s.add_dependency 'activesupport', '>= 5.2.2'

  s.add_development_dependency "simplecov"
  s.add_development_dependency "rspec"
  s.add_development_dependency "codecov", ">= 0.1.10"
end
