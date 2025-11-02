# Docker Hub Setup Guide for Your Loomio Fork

This guide will help you publish your Loomio fork's Docker images to Docker Hub.

## Prerequisites

- A Docker Hub account (create one at https://hub.docker.com if you don't have one)
- Admin access to this GitHub repository
- **GitHub Actions must be enabled** (see ENABLE_ACTIONS.md if not already done)

## Step 1: Create a Docker Hub Repository

1. Go to https://hub.docker.com
2. Sign in to your account
3. Click "Create Repository"
4. Fill in the details:
   - **Repository Name**: `loomio` (or whatever you prefer)
   - **Visibility**: Choose "Public" or "Private"
   - **Description**: Your fork of Loomio with ARM64 support
5. Click "Create"

Your repository will be at: `wizmoisa/loomio`

## Step 2: Generate Docker Hub Access Token

For security, use an access token instead of your password:

1. In Docker Hub, click your username (top right) → "Account Settings"
2. Go to "Security" → "Access Tokens"
3. Click "Generate New Token"
4. Give it a name (e.g., "GitHub Actions Loomio")
5. Set permissions to "Read, Write, Delete"
6. Click "Generate"
7. **Copy the token immediately** (you won't see it again!)

## Step 3: Configure GitHub Secrets

Add your Docker Hub credentials to GitHub:

1. Go to your GitHub repository: `https://github.com/etiennechabert/loomio`
2. Click "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add the first secret:
   - **Name**: `DOCKER_USERNAME`
   - **Value**: `wizmoisa`
   - Click "Add secret"
5. Click "New repository secret" again
6. Add the second secret:
   - **Name**: `DOCKER_PASSWORD`
   - **Value**: The access token you copied in Step 2
   - Click "Add secret"

## Step 4: Update the Workflow (Optional)

If you want to publish to your own Docker Hub account instead of `loomio/loomio`, update the workflow file:

Open `.github/workflows/docker_image.yml` and change line 36:

**Note**: This is already configured to use `wizmoisa/loomio`. If you want to change it, edit line 44 in `.github/workflows/docker_image.yml`.

## Step 5: Enable GitHub Actions (If Not Already Enabled)

⚠️ **Important**: GitHub Actions are disabled by default on forked repositories.

See **ENABLE_ACTIONS.md** for detailed instructions on how to enable them.

Quick steps:
1. Go to: https://github.com/etiennechabert/loomio/actions
2. Click "I understand my workflows, go ahead and enable them"

## Step 6: Push to GitHub

Push your changes to trigger the workflow:

```bash
git push origin master
```

## Step 7: Verify the Build

1. Go to your GitHub repository
2. Click the "Actions" tab
3. You should see a new workflow run for "Publish Docker image"
4. Click on it to see the build progress
5. Wait for it to complete (this may take 10-30 minutes for multi-platform builds)

## Step 8: Use Your Images

Once the build completes, your images will be available on Docker Hub:

```bash
# Pull your image (Docker will automatically select the right architecture)
docker pull wizmoisa/loomio:master

# Or use a specific tag
docker pull wizmoisa/loomio:latest
```

## Image Tags

The workflow automatically creates tags based on:
- **Branch pushes**: `branch-name` (e.g., `master`, `develop`)
- **Releases**: `version` (e.g., `v2.1.0`), `latest`
- **PR branches**: `pr-123`

## Troubleshooting

### Build Fails with Authentication Error

- Check that `DOCKER_USERNAME` and `DOCKER_PASSWORD` are set correctly in GitHub Secrets
- Verify the access token has "Read, Write, Delete" permissions
- Try regenerating the access token

### Build is Slow

Multi-platform builds take longer because they build for both AMD64 and ARM64. This is normal and can take 10-30 minutes depending on GitHub Actions runners.

### "HAVESECRET is null" Warning

If you see this in the logs, it means the secrets aren't configured. Follow Step 3 to add them.

### Want to Test Without Pushing?

You can test the build locally:

```bash
# Make the script executable if not already
chmod +x build_multiplatform.sh

# Run it and choose 'n' when asked about pushing
./build_multiplatform.sh test
```

## Updating Images

Every time you push to GitHub or create a release, the workflow will automatically:
1. Build new images for both AMD64 and ARM64
2. Push them to Docker Hub with appropriate tags
3. Make them available for pulling

## Additional Resources

- Docker Hub: https://hub.docker.com
- GitHub Actions Docs: https://docs.github.com/en/actions
- Docker Buildx Docs: https://docs.docker.com/buildx/working-with-buildx/

## Questions?

If you encounter issues:
1. Check the GitHub Actions logs for detailed error messages
2. Verify your Docker Hub credentials
3. Ensure your Docker Hub repository exists and is accessible
4. Check that the repository visibility matches your needs (public vs private)
