#!/usr/bin/env bash

set -ae

: ${BASE_DIR='/src'}
: ${BUILD_DIR="$BASE_DIR/build"}
: ${MODULE_NAME="$1"}
: ${MODULE_URL=$(jq -r ".modules.$MODULE_NAME.source_url" < "$BASE_DIR"/config.json)}
: ${MODULE_VERSION=$(jq -r ".modules.$MODULE_NAME.version" < "$BASE_DIR"/config.json)}
: ${NGINX_VERSION=$(jq -r '.nginx_version' < "$BASE_DIR"/config.json)}
: ${NGINX_URL="http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"}
: ${SHARED_LIBRARY=$(jq -r ".modules.$MODULE_NAME.library_name" < "$BASE_DIR"/config.json)}

# Clean build directory
if [ -d "$BUILD_DIR" ]; then
  rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir "$BUILD_DIR"

# Get source
curl -kLs "$NGINX_URL" | tar zxC "$BUILD_DIR"
curl -kLs "$MODULE_URL"v"$MODULE_VERSION".tar.gz | tar zxC "$BUILD_DIR"

# Compile
cd "$BUILD_DIR"/nginx-"$NGINX_VERSION"
./configure --add-dynamic-module=../nginx-module-"$MODULE_NAME"-"$MODULE_VERSION"
make

# Build RPM
mkdir -p "$BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo "%_topdir $BUILD_DIR" > ~/.rpmmacros
cp "$BUILD_DIR"/nginx-"$NGINX_VERSION"/objs/"$SHARED_LIBRARY" "$BUILD_DIR"/SOURCES/
for source in $(jq -r ".modules.$MODULE_NAME.sources[]" < "$BASE_DIR"/config.json); do
  cp "$BUILD_DIR"/nginx-module-"$MODULE_NAME"-"$MODULE_VERSION"/"$source" "$BUILD_DIR"/SOURCES/
done
cp "$BASE_DIR"/spec/nginx-module-"$MODULE_NAME".spec "$BUILD_DIR"/SPECS/
cd "$BUILD_DIR"
rpmbuild -bb SPECS/nginx-module-"$MODULE_NAME".spec
