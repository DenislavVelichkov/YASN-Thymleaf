#!/bin/bash

main() {
 build_docker_image "$@"
 build_deployments "$@"
 cleanup_old_image "$@"
}

build_docker_image() {
  version=""
  environment=""
  dockerfile=""
  component=""

  while getopts "v:e:f:c:" opt; do
    case $opt in
      v) version="$OPTARG" ;;
      e) environment="$OPTARG" ;;
      f) dockerfile="$OPTARG" ;;
      c) component="$OPTARG" ;;
      *) echo "Usage: $0 -v <version> -e <environment> -c <component> [-f <dockerfile>]" >&2
         exit 1 ;;
    esac
  done

  if [ -z "$version" ] || [ -z "$environment" ] || [ -z "$component" ]; then
    echo "Usage: $0 -v <version> -e <environment> -c <component> [-f <dockerfile>]" >&2
    exit 1
  fi

  if [ -z "$dockerfile" ]; then
    dockerfile="Dockerfile.$environment"
  fi

  # Change to the component directory
#  cd "../$component" || exit 1

  image_name="dvelichkov88/private-repo"
  image_tag="$component-$version"

  if [ ! -f "$dockerfile" ]; then
    echo "Error: Dockerfile not found: $dockerfile" >&2
    exit 1
  fi

  docker build -t "$image_name:$image_tag" -f "$dockerfile" .
}

build_deployments() {
  docker login
  docker push "dvelichkov88/private-repo:$component-$version"
}

cleanup_old_image() {
  # Remove the image
  docker image prune -f
}

main "$@"
