GO_CMD=go
GO_TEST=${GO_CMD} test
GO_BUILD=${GO_CMD} build
RELEASER_CMD=goreleaser
RELEASE=${RELEASER_CMD} release
LINTER_CMD=golangci-lint
LINT=${LINTER_CMD} run
BINARY_NAME=gremlins
COVER_OUT=coverage.out
TARGET=dist
BIN=${TARGET}/bin

.PHONY: all snap
all: lint test build
snap: lint test snapshot

build: ${BIN}/${BINARY_NAME}

${BIN}/${BINARY_NAME}:
	mkdir -p ${BIN}
	${GO_BUILD} -o ${BIN}/${BINARY_NAME} cmd/gremlins/main.go

.PHONY: test
test:
	${GO_TEST} ./...

.PHONY: cover
cover: ${COVER_OUT}

${COVER_OUT}:
	${GO_TEST} -cover -coverprofile ${COVER_OUT} ./...

.PHONY: lint
lint:
	${LINT} ./...

.PHONY: snapshot
snapshot:
	${RELEASE} --snapshot --rm-dist

.PHONY: clean
clean:
	go clean
	rm -rf -- ${TARGET}
	rm -f -- coverage.out