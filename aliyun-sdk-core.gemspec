# encoding: utf-8

Gem::Specification.new do |s|
    s.name               = "aliyunsdkcore"
    s.version            = "0.0.1"
    s.platform           = Gem::Platform::RUBY
    s.authors            = ["Alibaba Cloud SDK"]
    s.email              = ["sdk-team@alibabacloud.com"]
    s.description        = %q{Alibaba Cloud Ruby Core SDK}
    s.homepage           = %q{http://www.alibabacloud.com/}
    s.summary            = %q{Alibaba Cloud Ruby Core SDK}
    s.rubyforge_project  = "aliyunsdkcore"
    s.license            = "MIT"
    s.files              = ["lib/*.rb"]
    s.test_files         = ["test/test_*.rb"]
    s.require_paths      = ["lib"]

    s.add_development_dependency "rake"

end