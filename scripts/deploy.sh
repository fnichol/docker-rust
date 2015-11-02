#!/usr/bin/env sh
set -eu

banner() { echo "--> $*"; }
info() { echo "    $*"; }

IMAGE="${1:-${IMAGE}}"

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

banner "Deploy $IMAGE complete"
