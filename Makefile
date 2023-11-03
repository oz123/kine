TARGETS := $(shell ls scripts | grep -v \\.sh)

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/v0.6.0/dapper-$$(uname -s)-$$(uname -m) > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

.DEFAULT_GOAL := ci

GIT_REV=$(shell git describe --always --dirty)

.PHONY: build
build-test-image:
	docker build -t kine:test-$(GIT_REV) -t rancher/kine:$(GIT_REV)-amd64  -f Dockerfile.test .

RUN_TEST_OPTS := run --privileged -i -e ARCH -e REPO -e TAG  -e DRONE_TAG -e IMAGE_NAME -v /var/run/docker.sock:/var/run/docker.sock

.PHONY: test-postgresql
test-postgresql:
	docker $(RUN_TEST_OPTS) kine:test-$(GIT_REV) "./scripts/test postgres"

.PHONY: test-sqlite
test-sqlite:
	docker $(RUN_TEST_OPTS) kine:test-$(GIT_REV) "./scripts/test sqlite"
