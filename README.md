# Rust Programming Language Docker Images

[![Build Status](https://travis-ci.org/fnichol/docker-rust.svg?branch=master)](https://travis-ci.org/fnichol/docker-rust)

## Supported tags

- [`nightly` (*nightly/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/nightly/Dockerfile)
- [`nightly-slim` (*nightly/slim/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/nightly/slim/Dockerfile)
- [`1.4.0` (*1.4.0/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.4.0/Dockerfile)
- [`1.4.0-musl` (*1.4.0/musl/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.4.0/musl/Dockerfile)
- [`1.4.0-slim` (*1.4.0/slim/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.4.0/slim/Dockerfile)
- [`1.3.0` (*1.3.0/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.3.0/Dockerfile)
- [`1.3.0-slim` (*1.3.0/slim/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.3.0/slim/Dockerfile)
- [`1.2.0` (*1.2.0/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.2.0/Dockerfile)
- [`1.2.0-slim` (*1.2.0/slim/Dockerfile*)](https://github.com/fnichol/docker-rust/blob/master/1.2.0/slim/Dockerfile)

## What is Rust?

Rust is a general-purpose, multi-paradigm, compiled programming language developed by Mozilla Research. It is designed to be a "safe, concurrent, practical language", supporting pure-functional, concurrent-actor, imperative-procedural, and object-oriented styles.

> [wikipedia.org/wiki/Rust_(programming_language)](http://en.wikipedia.org/wiki/Rust_%28programming_language%29)

![logo](https://raw.githubusercontent.com/fnichol/docker-rust/master/logo.png)

## How to use this image

### Compile your app or library inside a Docker container

There may be occasions where it is not appropriate to run your app inside a container. To compile, but not run your app inside the instance, you can write something like this:

```console
docker run --rm -v "$PWD":/src fnichol/rust:1.4.0 cargo build --release
```

This will add your current directory as a volume to the container and run the command `cargo build --release` which will perform a release build (i.e. no debug symbols) of your project and output the executable under `./target/release/`. Alternatively, if you have a `Makefile`, you can run the `make` command inside your container.

```console
docker run --rm -v "$PWD":/src fnichol/rust:1.4.0 make
```

### Run your app inside a Docker container

While you are strongly encouraged to repackage a smaller Docker image with your compiled app for production use, it may be useful to run your app in development. For this, you can invoke `cargo run`:

```console
docker run --rm -v "$PWD":/src fnichol/rust:1.4.0 cargo run
```

### Caching CARGO_HOME

All the images set the `CARGO_HOME` environment variable to `/cargo` which means that you can use the [data volume pattern](http://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container) to cache the contents of `/cargo` between runs of containers. First, you need to set up a data volume container to host the Cargo home:

```console
docker create -v /cargo --name cargo-cache tianon/true /bin/true
```

Finally, use the `--volumes-from` flag when starting containers to mount `/cargo` in:

```console
docker run --rm -v "$PWD":/src --volumes-from cargo-cache fnichol/rust:1.4.0 cargo build
```

## Image variants

The `fnichol/rust` images come in many flavors, each designed for a specific use case.

### `fnichol/rust:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one.

### `fnichol/rust:<version>-slim`

This image does not contain the common packages contained in the default tag and only contains the minimal packages needed to run `rustc` and `cargo` for most projects. Unless you are working in an evironment where **only** the rust image will be deployed and you have space constraints, we highly recommend using the default image of this repository.

### `fnichol/rust:<version>-musl`

This image has a source-build version of Rust (and Cargo) which is has has [musl](http://www.musl-libc.org/) support with the compiler. This enables a `--target x86_64-unknown-linux-musl` target for `rustc` and `cargo build` which can lead to completely static binaries with no reliance on a libc at runtime. For more information, check out the [Rust book](https://doc.rust-lang.org/stable/book/advanced-linking.html) and this [Rust pull request](https://github.com/rust-lang/rust/pull/24777) with more details.

## License

View [license information](https://github.com/rust-lang/rust/blob/master/LICENSE-MIT) for the software contained in this image.

## Supported Docker versions

This image is officially supported on Docker version 1.8.3.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

## User feedback

### Documentation

Documentation for this image is contained in this [README.md](https://github.com/fnichol/docker-rust/tree/master/README.md).

### Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/fnichol/docker-rust/issues).


### Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/fnichol/docker-rust/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

