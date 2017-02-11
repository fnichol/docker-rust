#!/usr/bin/env bash
set -eu
if [ -n "${DEBUG:-}" ]; then set -x; fi

# Implementation is highly inspired and based from the work of Christoph Grabo
# in https://github.com/asaaki/rust-musl/blob/master/tools/scripts/build.sh.
# Very many thanks!

: ${MUSL_VERSION:=1.1.16}
: ${BUILDROOT:=/prep}

musl_root=/usr/local/musl

banner() { echo "--> $*"; }
info() { echo "    $*"; }

download() {
  if [ -f "$2" ]; then
    info "File $2 exists, re-using..."
  else
    info "Downloading ${2}..."
    curl -fsSL "$1" -o "$2"
    info "Download complete."
  fi
}

mkdir_and_pushd() {
  mkdir -p $1
  pushd $1
}

build_musl() {
  banner "Building musl $MUSL_VERSION..."

  download \
    "http://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz" \
    musl.tar.gz

  mkdir_and_pushd musl
    tar xfz ../musl.tar.gz --strip-components 1
    ./configure --disable-shared --prefix=$musl_root
    make
    make install
  popd
  info "musl build complete."
}

mkdir -p "$BUILDROOT"
pushd "$BUILDROOT"
  time (build_musl)
popd
