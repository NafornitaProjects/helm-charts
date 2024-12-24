#!/bin/bash
set -e

CHART_DIR=$1
VERSION_TYPE=${2:-auto}

if [[ -z "$CHART_DIR" ]]; then
  echo "Usage: bump_version.sh <chart-dir> [major|minor|patch|auto]"
  exit 1
fi

CURRENT_VERSION=$(grep '^version:' $CHART_DIR/Chart.yaml | awk '{print $2}')

if [[ "$VERSION_TYPE" == "major" ]]; then
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1+1".0.0"}')
elif [[ "$VERSION_TYPE" == "minor" ]]; then
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2+1".0"}')
elif [[ "$VERSION_TYPE" == "patch" ]]; then
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."$3+1}')
else
  if git log -1 --pretty=%B | grep -q 'BREAKING CHANGE'; then
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1+1".0.0"}')
  elif git log -1 --pretty=%B | grep -q '^feat'; then
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2+1".0"}')
  else
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."$3+1}')
  fi
fi

sed -i "s/^version:.*/version: $NEW_VERSION/" $CHART_DIR/Chart.yaml
echo "Updated $CHART_DIR/Chart.yaml to version $NEW_VERSION"

git add $CHART_DIR/Chart.yaml
git commit -m "ci: bump version to $NEW_VERSION for $CHART_DIR"
