ifeq ($(strip $(VERSION_STRING)),)
VERSION_STRING := $(shell git rev-parse --short HEAD)
endif

BINDIR    := $(CURDIR)/bin
PLATFORMS := linux/arm/watchtv-Linux-arm7
BUILDCOMMAND := go build -trimpath -ldflags "-X main.Version=${VERSION_STRING}"

temp = $(subst /, ,$@)
os = $(word 1, $(temp))
arch = $(word 2, $(temp))
label = $(word 3, $(temp))

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
SHACOMMAND := shasum -a 256
else
SHACOMMAND := sha256sum
endif

.DEFAULT_GOAL := build

.PHONY: release
build-all: $(PLATFORMS)

$(PLATFORMS):
	GOOS=$(os) GOARM=7 GOARCH=$(arch) CGO_ENABLED=0 $(BUILDCOMMAND) -o "bin/$(label)"
	$(SHACOMMAND) "bin/$(label)" > "bin/$(label).sha256"

.PHONY: latest
latest:
	echo ${VERSION_STRING} > bin/latest

.PHONY: lint
lint:
	golangci-lint run

.PHONY: test
test:
	 go test -p 4 -coverprofile=coverage.txt -covermode=atomic ./...

.PHONY: build
build:
	 $(BUILDCOMMAND) -o ${BINDIR}/WatchTV

.PHONY: dep
dep:
	go mod tidy