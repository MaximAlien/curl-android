#!/bin/bash

set -e
set -x

BUILD_DIR=$(pwd)/build
rm -rf $BUILD_DIR
mkdir $BUILD_DIR

CURL_DIR="$(pwd)/curl"
SSL_DIR="$(pwd)/openssl"
ZLIB_DIR="$(pwd)/zlib"
NDK_DIR="/Users/mmakhun/Library/Android/sdk/ndk-bundle"

PLATFORM="android-21"

TOOL=arm64-v8a
ARCH=arm64-v8a
HOST=aarch64-linux-android
SYSROOT=arch-arm64 # /Users/username/Library/Android/sdk/ndk-bundle/platforms/android-28/

# Configure toolchain
TOOLCHAIN=toolchain
echo "Removing existing toolchain"
rm -rf "$TOOLCHAIN"

$NDK_DIR/build/tools/make-standalone-toolchain.sh --platform=$PLATFORM --install-dir=$TOOLCHAIN --toolchain=$HOST --abis=$ARCH

export ANDROID_SYSROOT=$NDK_DIR/platforms/$PLATFORM/$SYSROOT

# Setup cross-compile environment
export CC=$(pwd)/toolchain/bin/aarch64-linux-android-gcc
export CXX=$(pwd)/toolchain/bin/aarch64-linux-android-g++
export AR=$(pwd)/toolchain/bin/aarch64-linux-android-ar
export AS=$(pwd)/toolchain/bin/aarch64-linux-android-as
export LD=$(pwd)/toolchain/bin/aarch64-linux-android-ld
export RANLIB=$(pwd)/toolchain/bin/aarch64-linux-android-ranlib
export NM=$(pwd)/toolchain/bin/aarch64-linux-android-nm
export STRIP=$(pwd)/toolchain/bin/aarch64-linux-android-strip

# echo "Configuring openssl"
# cd $SSL_DIR
# git clean -fdx

# echo "Modify openssl makefile to remove version from soname"
# sed -i.bak 's/^SHLIB_EXT=\.so\..*/SHLIB_EXT=\.so/' Makefile
# sed -i.bak 's/LIBVERSION=[^ ]* /LIBVERSION= /g' Makefile
# sed -i.bak 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile

# ./Configure linux-generic64 -D__ANDROID_API__=21 no-asm shared no-cast no-idea no-camellia no-whirpool --openssldir=$BUILD_DIR/openssl/$ARCH --prefix=$BUILD_DIR/openssl/$ARCH

# echo "Building openssl"

# echo "make depend"
# make depend

# echo "make"
# make -j4

# echo "Installing openssl to $BUILD_DIR/openssl/$ARCH"
# make install

# echo "Cleaning up openssl"
# make clean

# curl
echo "Setting flags for configure"
# export SSL_DIR=$openssl_directory
# export CFLAGS="--sysroot=$ANDROID_SYSROOT"
# export CPPFLAGS="--sysroot=$ANDROID_SYSROOT"
# export CXXFLAGS="--sysroot=$ANDROID_SYSROOT"
# export LIBS="-lcrypto -lssl -lz -ldl -lpthread"
# export CPPFLAGS="$CFLAGS -I$TOOLCHAIN/include -DANDROID -DCURL_STATICLIB"
export LDFLAGS="-L/obj/local/arm64-v8a"

echo "Configuring curl"
cd $CURL_DIR
git clean -fdx
rm -rf "$CURL_DIR/configure"
./buildconf

# --with-ssl="$SSL_DIR"
# --with-darwinssl
./configure --host=$HOST --target=$HOST --with-zlib="$ZLIB_DIR" --with-sysroot=$ANDROID_SYSROOT --disable-soname-bump --prefix=$BUILD_DIR/curl/$ARCH

# echo "Modifying libtool to generate shared library without version in name"
# sed -i.bak 's/^soname_spec=\"\(.*\)\\\$major\"$/soname_spec=\"\1\"/' libtool
# sed -i.bak 's/^version_type=linux$/version_type=none/' libtool


# echo "Building curl"
# make -j4

# echo "Installing curl"
# make install

echo "Done"