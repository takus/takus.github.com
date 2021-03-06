#!/bin/sh
# Install a Hugo, https://gohugo.io/

HUGO_VERSION="0.53"
HUGO_DIR=${HUGO_DIR:="$HOME/hugo"}

set -e

CACHED_DOWNLOAD="${HOME}/cache/hugo_${HUGO_VERSION}_linux-64bit.tar.gz"
mkdir -p "${HUGO_DIR}"
wget --continue \
	--output-document "${CACHED_DOWNLOAD}" \
	"https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-64bit.tar.gz"
tar xvzf "${CACHED_DOWNLOAD}" -C "${HUGO_DIR}"
ln -s "${HUGO_DIR}/hugo" "${HOME}/bin/hugo"

hugo version
