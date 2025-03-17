#!/bin/bash

set -e

# Get the latest tag (finds latest version tag)
LATEST_TAG=$(git describe --tags --match "v*" --abbrev=0 2>/dev/null || echo "v0.0.0")

# Extract major, minor, patch, and rc number
if [[ $LATEST_TAG =~ v([0-9]+)\.([0-9]+)\.([0-9]+)(-rc\.([0-9]+))? ]]; then
  MAJOR="${BASH_REMATCH[1]}"
  MINOR="${BASH_REMATCH[2]}"
  PATCH="${BASH_REMATCH[3]}"
  RC_NUMBER="${BASH_REMATCH[5]:-0}"  # Default to 0 if not an RC
else
  MAJOR=0
  MINOR=0
  PATCH=0
  RC_NUMBER=0
fi

# Get latest commit message
COMMIT_MSG=$(git log -1 --pretty=%B)

if [[ "$RC_NUMBER" == "0" ]]; then
  # Not an RC, create a new RC based on commit type
  if [[ $COMMIT_MSG == "feat!"* ]] || [[ $COMMIT_MSG == "fix!"* ]]; then
    ((MAJOR++))
    MINOR=0
    PATCH=0
    RC_NUMBER=1
    NEW_VERSION="v$MAJOR.0.0-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "feat"* ]]; then
    ((MINOR++))
    PATCH=0
    RC_NUMBER=1
    NEW_VERSION="v$MAJOR.$MINOR.0-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "fix"* ]]; then
    ((PATCH++))
    RC_NUMBER=1
    NEW_VERSION="v$MAJOR.$MINOR.$PATCH-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "release" ]]; then
    echo "No existing RC to release."
    exit 1
  else
    echo "No version bump needed"
    exit 0
  fi
else
  # Already on an RC, increment the RC number
  if [[ $COMMIT_MSG == "feat!"* ]] || [[ $COMMIT_MSG == "fix!"* ]]; then
    ((MAJOR++))
    MINOR=0
    PATCH=0
    RC_NUMBER=1
    NEW_VERSION="v$MAJOR.0.0-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "feat"* ]] || [[ $COMMIT_MSG == "fix"* ]]; then
    ((RC_NUMBER++))
    NEW_VERSION="v$MAJOR.$MINOR.$PATCH-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "release" ]]; then
    # Promote RC to stable release (remove -rc.X)
    NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
  else
    echo "No version bump needed"
    exit 0
  fi
fi

# Tag the commit with the new version
git tag "$NEW_VERSION"
git push origin "$NEW_VERSION"

echo "Tagged with $NEW_VERSION"
