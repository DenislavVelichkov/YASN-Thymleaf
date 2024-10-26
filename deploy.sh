#!/bin/bash

usage() {
  echo "Usage: $0 -n <namespace> [-p <docker_pat>]" 1>&2
  echo "  -n <namespace>    Kubernetes namespace to use"
  echo "  -p <docker_pat>   Docker Personal Access Token (PAT). If not provided, you will be prompted to enter it."
  exit 1
}

namespace=""
docker_pat=""

while getopts ":n:p:" o; do
    case "${o}" in
        n)
            namespace=${OPTARG}
            ;;
        p)
            docker_pat=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${namespace}" ]; then
    usage
fi

# Docker PAT Authentication Setup
if [ -z "$docker_pat" ]; then
  read -sp "Enter your Docker Personal Access Token (PAT): " docker_pat
  echo
fi

# Check Docker authentication using PAT
echo "$docker_pat" | docker login --username dvelichkov88 --password-stdin || { echo "Docker login failed"; exit 1; }

# Get deployment and image details
deployment=$(k3s kubectl get deployment -n "$namespace" | awk 'NR==2{print $1}')
image=$(k3s kubectl describe pod -n "$namespace" "$deployment" | grep -E 'Image:' | awk '{print $2}')

echo "Deployment: $deployment"
echo "-and-"
echo "Image: $image"

# Delete existing deployment
k3s kubectl delete deployment -n "$namespace" "$deployment"

sleep 4

# Create namespace and Docker registry secret
k3s kubectl create namespace "${namespace}"
k3s kubectl create secret docker-registry regcred -n "${namespace}" \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=dvelichkov88 \
  --docker-password="$docker_pat" \
  --docker-email=dvelichkov.bmc@gmail.com

# Apply configuration and secrets
k3s kubectl apply -f "${namespace}"-configuration.yaml
k3s kubectl apply -f "${namespace}"-secrets.yaml

if [ $? -eq 0 ]; then
    echo "Deployment done!"
else
    exit 1
fi
