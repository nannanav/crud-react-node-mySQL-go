#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Fetch latest tags
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
LATEST_RC_TAG=$(git tag --list "v*-rc.*" | sort -V | tail -n1 || echo "")

# Extract version numbers from latest stable and RC tags
PREV_STABLE_MAJOR=$(echo "$LATEST_TAG" | cut -d. -f1 | tr -d 'v')
PREV_STABLE_MINOR=$(echo "$LATEST_TAG" | cut -d. -f2)
PREV_STABLE_PATCH=$(echo "$LATEST_TAG" | cut -d. -f3)

if [[ $LATEST_RC_TAG == v* ]]; then
  RC_MAJOR=$(echo "$LATEST_RC_TAG" | cut -d. -f1 | tr -d 'v')
  RC_MINOR=$(echo "$LATEST_RC_TAG" | cut -d. -f2)
  RC_PATCH=$(echo "$LATEST_RC_TAG" | cut -d. -f3 | cut -d- -f1)
  RC_NUMBER=$(echo "$LATEST_RC_TAG" | rev | cut -d. -f1 | rev)
else
  RC_MAJOR=$PREV_STABLE_MAJOR
  RC_MINOR=$PREV_STABLE_MINOR
  RC_PATCH=$PREV_STABLE_PATCH
  RC_NUMBER=0
fi

# Determine if RC already introduced a major/minor/patch bump
HAS_MAJOR_BUMP=$([[ "$RC_MAJOR" -gt "$PREV_STABLE_MAJOR" ]] && echo true || echo false)
HAS_MINOR_BUMP=$([[ "$RC_MINOR" -gt "$PREV_STABLE_MINOR" ]] && echo true || echo false)
HAS_PATCH_BUMP=$([[ "$RC_PATCH" -gt "$PREV_STABLE_PATCH" ]] && echo true || echo false)

# Read the latest commit message
COMMIT_MSG=$(git log -1 --pretty=%B)

# Version bump logic
echo "executing version bump logic"
if [[ "$RC_NUMBER" == "0" ]]; then
  # If not already on an RC, determine version bump based on commit message
  if [[ $COMMIT_MSG == "feat!"* ]] || [[ $COMMIT_MSG == "fix!"* ]]; then
    ((PREV_STABLE_MAJOR++))
    PREV_STABLE_MINOR=0
    PREV_STABLE_PATCH=0
    RC_NUMBER=1
    NEW_VERSION="v$PREV_STABLE_MAJOR.0.0-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "feat"* ]]; then
    ((PREV_STABLE_MINOR++))
    PREV_STABLE_PATCH=0
    RC_NUMBER=1
    NEW_VERSION="v$PREV_STABLE_MAJOR.$PREV_STABLE_MINOR.0-rc.$RC_NUMBER"
  elif [[ $COMMIT_MSG == "fix"* ]]; then
    ((PREV_STABLE_PATCH++))
    RC_NUMBER=1
    NEW_VERSION="v$PREV_STABLE_MAJOR.$PREV_STABLE_MINOR.$PREV_STABLE_PATCH-rc.$RC_NUMBER"
  else
    echo "No version bump needed"
    exit 0
  fi
else
  # Already on an RC, handle RC number increments properly
  if [[ $COMMIT_MSG == "feat!"* ]] || [[ $COMMIT_MSG == "fix!"* ]]; then
    if [[ "$HAS_MAJOR_BUMP" == "true" ]]; then
      ((RC_NUMBER++))
    else
      ((RC_MAJOR++))
      RC_MINOR=0
      RC_PATCH=0
      RC_NUMBER=1
    fi
    NEW_VERSION="v$RC_MAJOR.0.0-rc.$RC_NUMBER"

  elif [[ $COMMIT_MSG == "feat"* ]]; then
    if [[ "$HAS_MAJOR_BUMP" == "true" ]] || [[ "$HAS_MINOR_BUMP" == "true" ]]; then
      ((RC_NUMBER++))
    else
      ((RC_MINOR++))
      RC_PATCH=0
      RC_NUMBER=1
    fi
    NEW_VERSION="v$RC_MAJOR.$RC_MINOR.0-rc.$RC_NUMBER"

  elif [[ $COMMIT_MSG == "fix"* ]]; then
    if [[ "$HAS_MAJOR_BUMP" == "true" ]] || [[ "$HAS_MINOR_BUMP" == "true" ]] || [[ "$HAS_PATCH_BUMP" == "true" ]]; then
      ((RC_NUMBER++))
    else
      ((RC_PATCH++))
      RC_NUMBER=1
    fi
    NEW_VERSION="v$RC_MAJOR.$RC_MINOR.$RC_PATCH-rc.$RC_NUMBER"

  elif [[ $COMMIT_MSG == "release" ]]; then
    # Promote RC to stable release (remove -rc.X)
    NEW_VERSION="v$RC_MAJOR.$RC_MINOR.$RC_PATCH"
  else
    echo "No version bump needed"
    exit 0
  fi
fi

# Output the new version and tag it in git
echo "New version: $NEW_VERSION"
git tag "$NEW_VERSION"
git push origin "$NEW_VERSION"
