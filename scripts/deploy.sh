#!/usr/bin/env sh
set -eu

if [ -n "${DEBUG:-}" ]; then
  set -x
fi

banner() { echo " ---> $*"; }
info() { echo "      $*"; }

IMAGE="${IMAGE_BASE}:$VERSION${VARIANT:+-$VARIANT}"

banner "Logging in to Docker Hub..."
docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
info "Login success."

banner "Pushing $IMAGE"
docker push "$IMAGE"
info "Pushing $IMAGE complete."

if [ -n "${LATEST:-}" ]; then
  latest_image="`echo $IMAGE | awk -F: '{print $1}'`:latest"
  banner "Pushing $latest_image"
  docker push "$latest_image"
  info "Pushing $latest_image complete."
fi

info "Cleaning up"
rm -rf "$HOME/.docker/config.json"

banner "Deploy $IMAGE complete."
