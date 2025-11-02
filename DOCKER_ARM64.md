# ARM64 Docker Support for Loomio

This document describes the ARM64 (Apple Silicon, AWS Graviton, etc.) support for Loomio Docker images.

## What Changed

The Loomio Docker build process has been updated to support multi-platform builds, enabling the images to run natively on both AMD64 (x86_64) and ARM64 (aarch64) architectures.

### Changes Made

1. **GitHub Actions Workflow** (`.github/workflows/docker_image.yml`):
   - Added QEMU setup for cross-platform emulation
   - Added Docker Buildx setup for multi-platform builds
   - Configured build to target both `linux/amd64` and `linux/arm64` platforms

2. **Build Script** (`build_multiplatform.sh`):
   - Created a helper script for building multi-platform images locally
   - Supports both local testing and pushing to Docker Hub

### Dockerfile Compatibility

The existing Dockerfile is already compatible with ARM64:
- Base image `ruby:3.4.7-slim` supports both AMD64 and ARM64
- All apt packages are available for ARM64
- Node.js from NodeSource repository supports ARM64
- Build tools and dependencies work on both architectures

## Using ARM64 Images

### Pulling from Docker Hub

Once the GitHub Actions workflow runs, the multi-platform images will be automatically available on Docker Hub. Docker will automatically pull the correct architecture for your system:

```bash
docker pull etiennechabert/loomio:latest
```

On ARM64 systems (Apple Silicon Macs, AWS Graviton, etc.), this will pull the ARM64 image.
On AMD64 systems, this will pull the AMD64 image.

### Building Locally

#### Quick Build (Single Platform)

For local development on your current architecture:

```bash
docker build -t etiennechabert/loomio:local .
```

#### Multi-Platform Build

To build for multiple platforms locally, use the provided script:

```bash
# Build and push to Docker Hub
./build_multiplatform.sh latest

# Build for local testing only (AMD64)
./build_multiplatform.sh latest
# (choose 'n' when prompted about pushing)
```

#### Manual Multi-Platform Build

If you prefer to use Docker Buildx directly:

```bash
# Create a new builder instance
docker buildx create --name multiplatform-builder --use

# Build for both platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag etiennechabert/loomio:latest \
  --push \
  .
```

**Note**: Multi-platform builds require pushing to a registry. You cannot load multi-platform images directly into your local Docker daemon.

## Benefits of ARM64 Support

1. **Apple Silicon Macs**: Native performance on M1/M2/M3 Macs without Rosetta emulation
2. **AWS Graviton**: Better price-performance ratio on ARM-based AWS instances
3. **Cloud Providers**: Access to ARM-based instances on various cloud platforms
4. **Energy Efficiency**: ARM64 typically offers better performance per watt

## Verification

To verify which architecture your image is running:

```bash
docker run --rm etiennechabert/loomio:latest uname -m
```

This will output:
- `x86_64` for AMD64 images
- `aarch64` for ARM64 images

## Troubleshooting

### Build is Slow

Multi-platform builds can be slower because:
- Building for non-native architectures uses QEMU emulation
- The build happens twice (once for each platform)

For local development, consider building only for your native platform.

### Cannot Load Multi-Platform Image Locally

Docker Buildx cannot load multi-platform images directly into the local Docker daemon. You have two options:

1. Push to a registry and pull from there
2. Build for a single platform using `--load`:
   ```bash
   docker buildx build --platform linux/amd64 --load -t etiennechabert/loomio:local .
   ```

## CI/CD Pipeline

The GitHub Actions workflow automatically builds and pushes multi-platform images when:
- Code is pushed to the repository
- A release is published

The workflow uses Docker Hub credentials stored in GitHub Secrets:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
