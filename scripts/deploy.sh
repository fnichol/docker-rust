#!/usr/bin/env sh
set -eu

banner() { echo "--> $*"; }
info() { echo "    $*"; }

image="${1:-${IMAGE}}"

banner "Logging in to Docker Hub..."
echo docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
info "Login success."

banner "Pushing $image"
echo docker push "$image"
info "Pushing $image complete."

if [ -n "${LATEST:-}" ]; then
  latest_image="`echo $image | awk -F: '{print $1}'`:latest"
  banner "Pushing $latest_image"
  echo docker push "$latest_image"
  info "Pushing $latest_image complete."
fi

info "Cleaning up"
rm -rf "$HOME/.docker/config.json"

banner "Deploy $image complete"
