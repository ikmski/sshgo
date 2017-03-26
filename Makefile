# meta
NAME := sshgo
VERSION := v1.0.0
REVISION := $(shell git rev-parse --short HEAD)
LDFLAGS := -X 'main.version=$(VERSION)' -X 'main.revision=$(REVISION)'

.PHONY: setup
## setup
setup:
	go get github.com/golang/lint
	go get github.com/golang/dep/...
	go get github.com/Songmu/make2help/cmd/make2help

.PHONY: update-deps
## update dependencies
update-deps: setup
	dep ensure

.PHONY: test
## run tests
test:
	go test

.PHONY: lint
## lint
lint: setup
	go vet
	for pkg in $$(ls -1 | grep .go); do\
		golint --set_exit_status $$pkg || exit $$?; \
	done

## build
bin/$(NAME): $(SRCS) update-deps
	go build \
		-a \
		-tags netgo \
		-installsuffix netgo \
		-ldflags "$(LDFLAGS)" \
		-o bin/$(NAME)


.PHONY: cross-build
## cross build
cross-build: update-deps
	for os in darwin linux windows; do \
		for arch in amd64 386; do \
			GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 go build \
				-a \
				-tags netgo \
				-installsuffix netgo \
				-ldflags "$(LDFLAGS)" \
				-o bin/$$os-$$arch/$(NAME); \
		done; \
	done


.PHONY: install
## install
install:
	go install $(LDFLAGS)

.PHONY: clean
## clean
clean:
	rm -rf bin/*

.PHONY: help
## show help
help:
	@make2help $(MAKEFILE_LIST)

