#!/bin/bash

set -e
set -x

BUILD_DIR="$(pwd)/build"
CURL_DIR="$(pwd)/curl"
SSL_DIR="$(pwd)/openssl"
ZLIB_DIR="$(pwd)/zlib"
TOOLCHAIN_DIR="$(pwd)/toolchain"
NDK_DIR="/home/mmakhun/Downloads/android-ndk-r20"

sudo rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

sudo rm -rf "$CURL_DIR"
mkdir "$CURL_DIR"

sudo rm -rf "$SSL_DIR"
mkdir "$SSL_DIR"

sudo rm -rf "$ZLIB_DIR"
mkdir "$ZLIB_DIR"

sudo rm -rf "$TOOLCHAIN_DIR"

git clone https://github.com/bagder/curl.git
git clone -b OpenSSL_1_0_2-stable --single-branch https://github.com/openssl/openssl.git
git clone https://github.com/madler/zlib.git

PLATFORM=android-28
TOOL=arm64-v8a
ARCH=arm64-v8a
HOST=aarch64-linux-android
SYSROOT=arch-arm6

$NDK_DIR/build/tools/make-standalone-toolchain.sh --platform=$PLATFORM --install-dir=$TOOLCHAIN_DIR --toolchain=$HOST --abis=$ARCH

export ANDROID_SYSROOT=$NDK_DIR/platforms/$PLATFORM/$SYSROOT
export CC=$(pwd)/toolchain/bin/aarch64-linux-android-gcc
export CXX=$(pwd)/toolchain/bin/aarch64-linux-android-g++
export AR=$(pwd)/toolchain/bin/aarch64-linux-android-ar
export AS=$(pwd)/toolchain/bin/aarch64-linux-android-as
export LD=$(pwd)/toolchain/bin/aarch64-linux-android-ld
export RANLIB=$(pwd)/toolchain/bin/aarch64-linux-android-ranlib
export NM=$(pwd)/toolchain/bin/aarch64-linux-android-nm
export STRIP=$(pwd)/toolchain/aarch64-linux-android/bin/strip

# zlib
echo "Configuring zlib"
cd "$ZLIB_DIR"
sed -i '199d' CMakeLists.txt
sed -i '189d' CMakeLists.txt
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$ZLIB_DIR/build ..
make
make install

$STRIP --strip-debug "$ZLIB_DIR/build/lib/libz.a"
$STRIP --strip-debug "$ZLIB_DIR/build/lib/libz.so"

cp "$ZLIB_DIR/build/lib/libz.a" "$BUILD_DIR"
cp "$ZLIB_DIR/build/lib/libz.so" "$BUILD_DIR"

# openssl 
echo "Configuring openssl"
cd "$SSL_DIR"

sed -i.bak 's/-soname=$$SHLIB$$SHLIB_SOVER$$SHLIB_SUFFIX/-soname=$$SHLIB/g' Makefile.shared

./Configure linux-generic64 -D__ANDROID_API__=28 no-asm shared no-cast no-idea no-camellia

echo "Modify openssl makefile to remove version from soname"
sed -i.bak 's/^SHLIB_EXT=\.so\..*/SHLIB_EXT=\.so/' Makefile
sed -i.bak 's/LIBVERSION=[^ ]* /LIBVERSION= /g' Makefile
sed -i.bak 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile

echo "Building openssl..."
make depend
make -j4 SHLIB_VERSION_NUMBER= LIBVERSION= SHLIB_EXT=.so CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" MAKE="make -e" all
sudo make install

$STRIP --strip-debug "$SSL_DIR/libcrypto.a"
$STRIP --strip-debug "$SSL_DIR/libcrypto.so" 
$STRIP --strip-debug "$SSL_DIR/libssl.a"
$STRIP --strip-debug "$SSL_DIR/libssl.so" 

cp "$SSL_DIR/libcrypto.a" "$BUILD_DIR"
cp "$SSL_DIR/libcrypto.so" "$BUILD_DIR"
cp "$SSL_DIR/libssl.a" "$BUILD_DIR"
cp "$SSL_DIR/libssl.so" "$BUILD_DIR"

# curl
export LIBS="-lcrypto -lssl -lz"
export CPPFLAGS="-I$SSL_DIR/include"
export LDFLAGS="-L/obj/local/arm64-v8a -L$SSL_DIR"

echo "Configuring curl"
cd "$CURL_DIR"

./buildconf
./configure --host=$HOST --target=$HOST --with-ssl="$SSL_DIR" --with-zlib="$ZLIB_DIR" --with-sysroot=$ANDROID_SYSROOT --disable-soname-bump --prefix=$BUILD_DIR/curl/$ARCH

echo "Modifying libtool to generate shared library without version in name"
sed -i.bak 's/^soname_spec=\"\(.*\)\\\$major\"$/soname_spec=\"\1\"/' libtool
sed -i.bak 's/^version_type=linux$/version_type=none/' libtool

echo "Building curl..."
make -j4
make install

$STRIP --strip-debug "$BUILD_DIR/curl/arm64-v8a/lib/libcurl.a"
$STRIP --strip-debug "$BUILD_DIR/curl/arm64-v8a/lib/libcurl.so"

echo "Done"