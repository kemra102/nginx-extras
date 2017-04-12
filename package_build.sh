#!/usr/bin/env bash

set -ae

: ${BASE_DIR='/src'}
: ${BUILD_DIR="$BASE_DIR/build"}
: ${MODULE_NAME="$1"}
: ${MODULE_URL=$(jq -r ".modules.$MODULE_NAME.source_url" < "$BASE_DIR"/config.json)}
: ${MODULE_FILENAME=$(jq -r ".modules.$MODULE_NAME.source_filename" < "$BASE_DIR"/config.json)}
: ${MODULE_LOCATION=$(jq -r ".modules.$MODULE_NAME.source_location" < "$BASE_DIR"/config.json)}
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
curl -kLs "$MODULE_URL$MODULE_VERSION".tar.gz | tar zxC "$BUILD_DIR"

# Compile
cd "$BUILD_DIR"/nginx-"$NGINX_VERSION"
./configure --add-dynamic-module=../"$MODULE_FILENAME""$MODULE_LOCATION" --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-file-aio --with-threads --with-ipv6 --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'
make

# Build RPM
mkdir -p "$BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo "%_topdir $BUILD_DIR" > ~/.rpmmacros

cp "$BUILD_DIR"/nginx-"$NGINX_VERSION"/objs/"$SHARED_LIBRARY" "$BUILD_DIR"/SOURCES/
for source in $(jq -r ".modules.$MODULE_NAME.sources[]" < "$BASE_DIR"/config.json); do
  cp "$BUILD_DIR"/"$MODULE_FILENAME"/"$source" "$BUILD_DIR"/SOURCES/
done
cp "$BASE_DIR"/spec/nginx-module-"$MODULE_NAME".spec "$BUILD_DIR"/SPECS/
cd "$BUILD_DIR"
rpmbuild -bb SPECS/nginx-module-"$MODULE_NAME".spec
