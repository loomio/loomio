# Enable GitHub Actions for Your Fork

## Issue

GitHub Actions are **disabled by default** on forked repositories for security reasons. This is why no workflows are running even though they're configured correctly.

## Solution

You need to manually enable GitHub Actions for your forked repository:

### Method 1: Via GitHub Web Interface (Recommended)

1. Go to your repository: **https://github.com/etiennechabert/loomio**

2. Click on the **"Actions"** tab at the top

3. You should see a message like:
   > "Workflows aren't being run on this forked repository"

   or

   > "Workflows disabled"

4. Click the green button that says:
   - **"I understand my workflows, go ahead and enable them"**

   or

   - **"Enable Actions"**

5. Your workflows will now be enabled!

### Method 2: Via Repository Settings

1. Go to: **https://github.com/etiennechabert/loomio/settings/actions**

2. Under "Actions permissions", select:
   - ✅ **"Allow all actions and reusable workflows"**

   or at minimum:

   - ✅ **"Allow actions created by GitHub"**
   - ✅ **"Allow actions by Marketplace verified creators"**

3. Click **"Save"**

4. Scroll down to "Fork pull request workflows from outside collaborators"

5. Select your preferred option (recommended: "Require approval for first-time contributors")

## Verify Actions are Enabled

After enabling:

1. Go to the **Actions** tab: https://github.com/etiennechabert/loomio/actions

2. You should see:
   - A list of workflows (if any have run)
   - OR "No workflow runs yet" (normal if nothing has triggered yet)

3. You should **NOT** see messages about workflows being disabled

## Trigger Your First Workflow Run

Once Actions are enabled, trigger a workflow by making a small change:

```bash
# Make a small change (e.g., add a comment to README)
echo "" >> README.md
git add README.md
git commit -m "Trigger GitHub Actions"
git push origin master
```

Or just push the pending changes:

```bash
git push origin master
```

## Expected Behavior

After pushing, two workflows will run:

1. **"Publish Docker image"** - Will skip building if Docker Hub secrets aren't set
2. **"tests"** - Will run the test suite

You can monitor them at: https://github.com/etiennechabert/loomio/actions

## Why This Happens

GitHub disables Actions on forks to prevent:
- Abuse of GitHub's free Actions minutes
- Malicious code execution through forked workflows
- Unauthorized use of secrets

This is a security feature and normal behavior for all forked repositories.

## Next Steps

After enabling Actions:

1. ✅ Enable GitHub Actions (this guide)
2. 📦 Set up Docker Hub (see DOCKERHUB_SETUP.md)
3. 🚀 Push changes to trigger your first build

## Troubleshooting

### I don't see the "Enable Actions" button

- Make sure you have admin permissions on the repository
- Try going directly to: https://github.com/etiennechabert/loomio/settings/actions

### Workflows still not running

- Check you're on the Actions tab: https://github.com/etiennechabert/loomio/actions
- Try making a new commit and pushing
- Check the workflow files have `on: push:` trigger configured

### "Resource not accessible by integration" error

- This usually means Actions are still disabled
- Follow Method 2 above to enable via Settings
