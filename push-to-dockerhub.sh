#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
else
    echo "File .env does not exist"
    exit 1
fi

if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
    echo "DOCKERHUB_USERNAME or DOCKERHUB_PASSWORD not set in .env"
    exit 1
fi

FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE_NAME:$DOCKERHUB_IMAGE_TAG"

echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

if [ $? -ne 0 ]; then
    echo "Error during login to Docker Hub"
    exit 1
fi

docker tag "$DOCKERHUB_IMAGE_NAME:$DOCKERHUB_IMAGE_TAG" "$FULL_IMAGE_NAME"

docker push "$FULL_IMAGE_NAME"

docker logout

echo "Image pushed to Docker Hub: $FULL_IMAGE_NAME"
