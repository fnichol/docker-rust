#!/usr/bin/env sh
set -eu

if [ -n "${DEBUG:-}" ]; then
  set -x
fi

banner() { echo " ---> $*"; }
info() { echo "      $*"; }

IMAGE="${IMAGE_BASE}:$VERSION${VARIANT:+-$VARIANT}"

cd "$VERSION"

banner "Building $IMAGE inside $VERSION"
docker build -t "$IMAGE" "${VARIANT:-.}"
info "Build complete."

if [ -n "${LATEST:-}" ]; then
  banner "Building ${IMAGE_BASE}:latest inside $VERSION"
  docker build -t "${IMAGE_BASE}:latest" "${VARIANT:-.}"
  info "Build complete."
fi
