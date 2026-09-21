#!/usr/bin/env bash

set -e

# get highest tag number, default to 0.0.0 if no tags exist yet
VERSION=`git describe --abbrev=0 --tags 2>/dev/null || echo "0.0.0"`

# replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

# get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]:-0}
VNUM2=${VERSION_BITS[1]:-0}
VNUM3=${VERSION_BITS[2]:-0}
VNUM3=$((VNUM3+1))

# create new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"

if [ -z "$NEW_TAG" ]; then
  echo "[auto-tag] Unable to determine new tag! Aborting!"
  exit 1
fi

echo "[auto-tag] Increasing \"$VERSION\" to \"$NEW_TAG\""

# get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null || true`

# only tag if no tag already
if [ -z "$NEEDS_TAG" ]; then
    git tag $NEW_TAG
    echo "[auto-tag] Tagged with $NEW_TAG"
    git push --tags
else
    echo "[auto-tag] Already a tag on this commit"
fi

echo $NEW_TAG > current_version

# collect changes since the previous tag (full log if this is the first tag)
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    CHANGES=`git log --pretty=format:%B ${VERSION}..${NEW_TAG} | sort | uniq`
else
    CHANGES=`git log --pretty=format:%B | sort | uniq`
fi
echo ${CHANGES} | sed ':a;N;$!ba;s/\n/\\\n/g' > changes

sed -i "s|<new-version>|${NEW_TAG}|" scripts/notification.sh
sed -i "s|<current-version>|${VERSION}|" scripts/notification.sh
