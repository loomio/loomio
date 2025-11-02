#!/bin/bash
# Script to build multi-platform Docker images for Loomio
# This builds images for both AMD64 and ARM64 architectures

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building multi-platform Docker image for Loomio${NC}"
echo -e "${BLUE}Platforms: linux/amd64, linux/arm64${NC}\n"

# Create a new builder instance if it doesn't exist
if ! docker buildx inspect multiplatform-builder &> /dev/null; then
    echo -e "${GREEN}Creating new buildx builder instance...${NC}"
    docker buildx create --name multiplatform-builder --use
else
    echo -e "${GREEN}Using existing buildx builder instance...${NC}"
    docker buildx use multiplatform-builder
fi

# Bootstrap the builder
docker buildx inspect --bootstrap

# Get the image tag from command line argument or use 'latest'
TAG=${1:-latest}
IMAGE_NAME="etiennechabert/loomio:${TAG}"

echo -e "\n${GREEN}Building image: ${IMAGE_NAME}${NC}"
echo -e "${GREEN}This may take a while...${NC}\n"

# Build and push (or load for local use)
# Use --push to push to registry, or --load to load locally (only works for single platform)
# For multi-platform, you need to push to a registry

read -p "Do you want to push to Docker Hub? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag "${IMAGE_NAME}" \
        --push \
        .
    echo -e "\n${GREEN}Successfully built and pushed multi-platform image: ${IMAGE_NAME}${NC}"
else
    echo -e "\n${BLUE}Building for local testing (AMD64 only)...${NC}"
    docker buildx build \
        --platform linux/amd64 \
        --tag "${IMAGE_NAME}" \
        --load \
        .
    echo -e "\n${GREEN}Successfully built local image: ${IMAGE_NAME}${NC}"
    echo -e "${BLUE}Note: Local load only supports single platform (AMD64)${NC}"
fi

echo -e "\n${GREEN}Done!${NC}"
