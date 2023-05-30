APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ibayro
BUILD.exe=go build -v -o kbot.exe -ldflags "-X="github.com/ibayro/kbot/cmd.appVersion=
BUILD.deb=go build -v -o kbot.deb -ldflags "-X="github.com/ibayro/kbot/cmd.appVersion=
BUILD.dmg=go build -v -o kbot.dmg -ldflags "-X="github.com/ibayro/kbot/cmd.appVersion=
WINDOWS=windows
LINUX=linux
MACOS=darwin
AMD=amd64
ARM=arm64
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
PWD=.

### kbot binaries creation for different operating systems and architectures. ###
windows: format get $(WINDOWS)	## Build kbot for Windows
linux:   format get $(LINUX) 	  ## Build kbot for Linux
darwin:  format get $(MACOS) 	  ## Build kbot for macOS

$(WINDOWS):
	CGO_ENABLED=0 env GOOS=${WINDOWS} GOARCH=${AMD} ${BUILD.exe}${VERSION}

$(LINUX):
	CGO_ENABLED=0 env GOOS=${LINUX} GOARCH=${AMD}   ${BUILD.deb}${VERSION}

$(MACOS):
	CGO_ENABLED=0 env GOOS=${MACOS} GOARCH=${ARM}   ${BUILD.dmg}${VERSION}

#$(MACOS):
	CGO_ENABLED=0 env GOOS=${MACOS} GOARCH=${AMD}   ${BUILD.dmg}${VERSION}

format:	
	gofmt -s -w ./
get:
	go get	
test:                                   ## Run unit tests
#	./scripts/test_unit.sh
	go test -v
build: format get windows linux darwin 	## Build all binaries
	@echo version: $(VERSION)
all: format get test build 		          ## Start format -> compile -> test -> build

### Docker containers creation ###

#Linux is set as a Default 
image:
	docker build -t ${REGISTRY}/${APP}_${VERSION}_${LINUX}_${AMD} --build-arg os=linux ${PWD}
image_windows:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${WINDOWS}-${AMD} --build-arg os=windows ${PWD}
image_mac:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${MACOS}-${ARM} --build-arg os=darwin ${PWD}
image_mac_amd64:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${MACOS}-${AMD} --build-arg os=darwin ${PWD}

### Docker container push to remote repo ###

#Linux is set as a Default 
push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${LINUX}-${AMD}
push_windows:
	docker push ${REGISTRY}/${APP}:${VERSION}-${WINDOWS}-${AMD}
push_mac:
	docker push ${REGISTRY}/${APP}:${VERSION}-${MACOS}-${ARM}
push_mac_amd64:
	docker push ${REGISTRY}/${APP}:${VERSION}-${MACOS}-${AMD}

clean.windows:  ## Remove Build for Windows
	rm -rf kbot.exe
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${WINDOWS}-${AMD}
clean.linux:    ## Remove Build for Linux
	rm -rf kbot.deb
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${LINUX}-${AMD}
clean.darwin:   ## Remove Build for macOS (x86-64)
	rm -rf kbot.dmg
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${MACOS}-${ARM}
clean.all:      ## Remove all previous build
	rm -rf kbot*
	docker rmi $(docker images -a -q)
help:           ## Display available commands and description
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
