.PHONY: test install build deploy

test:
	bundle exec rspec --format doc --exclude-pattern spec/**/*_integration_spec.rb
	bundle exec rspec --format doc -P spec/**/*_integration_spec.rb

deploy:
	$(eval VERSION := $(shell cat lib/aliyunsdkcore.rb | grep 'VERSION = ' | cut -d\" -f2))
	git release v$(VERSION) -m "Release v$(VERSION)"
	git push origin v$(VERSION)
	gem build aliyunsdkcore.gemspec
	gem push aliyunsdkcore-$(VERSION).gem

install:
	rm -rf vendor .bundle
	bundle install
