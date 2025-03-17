#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
shopt -s nocasematch

# Get latest stable release tag
LATEST_STABLE_TAG=$(git tag --list "v*" | grep -v "rc" | sort -V | tail -n1)

# Extract version numbers from the latest stable tag
if [[ -n "$LATEST_STABLE_TAG" ]]; then
  PREV_STABLE_MAJOR=$(echo "$LATEST_STABLE_TAG" | cut -d. -f1 | tr -d 'v')
  PREV_STABLE_MINOR=$(echo "$LATEST_STABLE_TAG" | cut -d. -f2)
  PREV_STABLE_PATCH=$(echo "$LATEST_STABLE_TAG" | cut -d. -f3)
else
  PREV_STABLE_MAJOR=0
  PREV_STABLE_MINOR=0
  PREV_STABLE_PATCH=0
fi

# Get latest RC tag
LATEST_RC_TAG=$(git tag --list "v*-rc.*" | sort -V | tail -n1)

if [[ -n "$LATEST_RC_TAG" ]]; then
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
# COMMIT_MSG="fix"

echo "LATEST_STABLE_TAG: $LATEST_STABLE_TAG"
echo "LATEST_RC_TAG: $LATEST_RC_TAG"
echo "COMMIT_MSG: $COMMIT_MSG"

# Version bump logic
echo "executing version bump logic"
if [[ "$RC_MAJOR" == "$PREV_STABLE_MAJOR" ]] || [[ "$RC_MINOR" == "$PREV_STABLE_MINOR" ]] || [[ "$RC_PATCH" == "$PREV_STABLE_PATCH" ]]; then
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
    echo "this will create new brand rc with a patch bump"
    echo "PREV_STABLE_PATCH: $PREV_STABLE_PATCH"
    ((PREV_STABLE_PATCH++))
    echo "PREV_STABLE_PATCH: $PREV_STABLE_PATCH"
    RC_NUMBER=1
    echo "RC_NUMBER: $RC_NUMBER"
    NEW_VERSION="v$PREV_STABLE_MAJOR.$PREV_STABLE_MINOR.$PREV_STABLE_PATCH-rc.$RC_NUMBER"
    echo "New version: $NEW_VERSION"
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
    echo "a"
    if [[ "$HAS_MAJOR_BUMP" == "true" ]] || [[ "$HAS_MINOR_BUMP" == "true" ]] || [[ "$HAS_PATCH_BUMP" == "true" ]]; then
      echo "b"
      ((RC_NUMBER++))
    else
      echo "c"
      ((RC_PATCH++))
      RC_NUMBER=1
    fi
    echo "d"
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

