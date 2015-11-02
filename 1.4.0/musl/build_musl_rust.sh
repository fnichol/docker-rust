#!/usr/bin/env bash
set -eu
if [ -n "${DEBUG:-}" ]; then set -x; fi

# Implementation is highly inspired and based from the work of Christoph Grabo
# in https://github.com/asaaki/rust-musl/blob/master/tools/scripts/build.sh.
# Very many thanks!

: ${MUSL_VERSION:=1.1.12}
: ${LLVM_VERSION:=3.7.0}
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

build_libunwind() {
  banner "Building libunwind $LLVM_VERSION..."

  download \
    "http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz" \
    llvm.tar.xz
  download \
    "http://llvm.org/releases/$LLVM_VERSION/libcxxabi-$LLVM_VERSION.src.tar.xz" \
    libcxxabi.tar.xz
  download \
    "http://llvm.org/releases/$LLVM_VERSION/libunwind-$LLVM_VERSION.src.tar.xz" \
    libunwind.tar.xz

  mkdir_and_pushd llvm
    tar xfJ ../llvm.tar.xz --strip-components 1

    mkdir_and_pushd projects/libcxxabi
      tar xfJ ../../../libcxxabi.tar.xz --strip-components 1
    popd

    mkdir_and_pushd projects/libunwind
      tar xfJ ../../../libunwind.tar.xz --strip-components 1
    popd

    sed -i 's#^\(include_directories\).*$#\0\n\1(../libcxxabi/include)#' \
      projects/libunwind/CMakeLists.txt

    mkdir_and_pushd projects/libunwind/build
      cmake \
        -DLLVM_PATH=../../.. \
        -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
        -DLIBUNWIND_ENABLE_SHARED=0 ..
      make -j"$(nproc)"
      cp lib/libunwind.a $musl_root/lib/
    popd
  popd
  info "libunwind build complete."
}

build_rust() {
  banner "Building Rust $RUST_VERSION..."
  if [ ! -d rust ]; then
    git clone --depth 1 --branch "$RUST_VERSION" \
      https://github.com/rust-lang/rust.git rust
  fi

  pushd rust
    ./configure --target=x86_64-unknown-linux-musl --musl-root=$musl_root
    make -j"$(nproc)"
    make install
  popd
  info "Rust build complete."
}

build_cargo() {
  banner "Building Cargo $CARGO_VERSION..."
  if [ ! -d cargo ]; then
    git clone https://github.com/rust-lang/cargo.git cargo
  fi

  pushd cargo
    git reset --hard "$CARGO_VERSION"
    git submodule update --init
    ./configure --target=x86_64-unknown-linux-gnu
    make -j"$(nproc)"
    make install
  popd
  info "Cargo build complete."
}

mkdir -p "$BUILDROOT"
pushd "$BUILDROOT"
  time (build_musl)
  time (build_libunwind)
  time (build_rust)
  time (build_cargo)

  echo -e '\n'
  banner "Rust build complete."
  info "Built Rust $(rustc --version) with rustc installed at $(which rustc)"
  info "Built Cargo $(cargo --version) with rustc installed at $(which cargo)"
  banner 'Choo choo!'
popd
