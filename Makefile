.PHONY: test install build deploy

test:
	rspec --format doc

deploy:
	$(eval VERSION := $(shell cat lib/aliyunsdkcore.rb | grep 'VERSION = ' | cut -d\" -f2))
	git release v$(VERSION) -m "Release v$(VERSION)"
	git push origin v$(VERSION)
	gem build aliyunsdkcore.gemspec
	gem push aliyunsdkcore-$(VERSION).gem

install:
	rm -rf vendor .bundle
	bundle install
