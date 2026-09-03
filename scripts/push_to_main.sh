#!/usr/bin/env bash
set -euo pipefail

# Usage: run this from the project root: ./scripts/push_to_main.sh
# This script stages all changes, commits with the provided message,
# pushes to the remote 'main' branch, and deletes the remote 'dev' branch.
# It DOES NOT change your local git user configuration.

COMMIT_MSG_FILE=".git_commit_message.txt"
if [ ! -f "$COMMIT_MSG_FILE" ]; then
  echo "Commit message file not found: $COMMIT_MSG_FILE"
  echo "Create the file with the commit message and re-run this script."
  exit 1
fi

COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Ensure working tree is clean enough
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Staging all changes..."
  git add -A
  git commit -m "$COMMIT_MSG"
else
  echo "No staged changes. Creating a no-op commit to record version bump if necessary..."
  git commit --allow-empty -m "$COMMIT_MSG"
fi

# Push current HEAD to remote main
echo "Pushing current HEAD to origin/main..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

git push origin HEAD:main

# Delete remote dev branch if it exists
if git ls-remote --exit-code --heads origin dev >/dev/null 2>&1; then
  echo "Deleting remote branch 'dev'..."
  git push origin --delete dev
else
  echo "Remote branch 'dev' not found; skipping delete."
fi

echo "Done. Pushed to origin/main and removed remote 'dev' (if existed)."
