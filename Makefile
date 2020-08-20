.PHONY: build install clean test integration dep release docker-build
VERSION=`egrep -o '[0-9]+\.[0-9a-z.\-]+' version.go`
GIT_SHA=`git rev-parse --short HEAD || echo`

build:
	@echo "Building confd..."
	@mkdir -p bin
	@go build -ldflags "-s -w -X main.GitSHA=Env-patch:${GIT_SHA}" -o bin/confd .
	@upx bin/confd

docker-build:
	@echo "Building docker image..."
	docker build -t confd:build -f Dockerfile.build .
	docker build -t confd -f Dockerfile.alpine .
	docker build -t confd-gui -f Dockerfile.alpine.gui .
	docker tag confd:latest npodewitz/confd:latest
	docker tag confd-gui:latest npodewitz/confd-gui:latest

install:
	@echo "Installing confd..."
	@install -c bin/confd /usr/local/bin/confd

clean:
	@rm -f bin/*

test:
	@echo "Running tests..."
	@go test `go list ./... | grep -v vendor/`

integration:
	@echo "Running integration tests..."
	@for i in `find ./integration -name test.sh`; do \
		echo "Running $$i"; \
		bash $$i || exit 1; \
		bash integration/expect/check.sh || exit 1; \
		rm /tmp/confd-*; \
	done

dep:
	@dep ensure

release:
	@docker build -q -t confd_builder -f Dockerfile.build.alpine .
	@for platform in darwin linux windows; do \
		if [ $$platform == windows ]; then extension=.exe; fi; \
		docker run -it --rm -v ${PWD}:/app -e "GOOS=$$platform" -e "GOARCH=amd64" -e "CGO_ENABLED=0" confd_builder go build -ldflags="-s -w -X main.GitSHA=${GIT_SHA}" -o bin/confd-${VERSION}-$$platform-amd64$$extension; \
	done
	@docker run -it --rm -v ${PWD}:/app -e "GOOS=linux" -e "GOARCH=arm64" -e "CGO_ENABLED=0" confd_builder go build -ldflags="-s -w -X main.GitSHA=${GIT_SHA}" -o bin/confd-${VERSION}-linux-arm64;
	@upx bin/confd-${VERSION}-*
