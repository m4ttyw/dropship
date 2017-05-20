#!/bin/bash -

set -eu

VERSION=$(git describe --abbrev=0 --tags)
REVCNT=$(git rev-list --count HEAD)
DEVCNT=$(git rev-list --count $VERSION)
if test $REVCNT != $DEVCNT
then
	VERSION="$VERSION.dev$(expr $REVCNT - $DEVCNT)"
fi
echo "VER: $VERSION"

GITCOMMIT=$(git rev-parse HEAD)
BUILDTIME=$(date -u +%Y/%m/%d-%H:%M:%S)

LDFLAGS="-X main.VERSION=$VERSION -X main.BUILDTIME=$BUILDTIME -X main.GITCOMMIT=$GITCOMMIT"
if [[ -n "${EX_LDFLAGS:-""}" ]]
then
	LDFLAGS="$LDFLAGS $EX_LDFLAGS"
fi

build() {
	echo "$1 $2 $3..."
	GOOS=$2 GOARCH=$3 go build \
		-tags bindata \
		-ldflags "$LDFLAGS" \
		-o bin/${1}-${4:-""}
}

go-bindata-assetfs -tags bindata res/...

build dropship linux arm linux-arm
build dropship linux amd64 linux-amd64
build dropship linux mipsle linux-mipsle
