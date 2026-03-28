#!/bin/bash
# Build script for git (RunixOS cross-compilation)
# Depends on: zlib, openssl, curl, expat

CROSS_CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -fuse-ld=lld"

GIT_MAKE_ARGS=(
    CC="$CROSS_CC"
    CFLAGS="-I$SYSROOT/Core/APIHeader -Wno-incompatible-pointer-types"
    LDFLAGS="-L$SYSROOT/Core/LibKit"
    prefix=/Core
    bindir=/Core/Bin
    libexecdir=/Core/LibKit/git-core
    datarootdir=/Core/StoreRoom
    sysconfdir=/Core/Config
    NO_TCLTK=1
    NO_GETTEXT=1
    NO_PERL=1
    NO_PYTHON=1
    EXPATDIR="$SYSROOT/Core"
    EXPAT_LIBEXPAT="-L$SYSROOT/Core/LibKit -lexpat"
    CURLDIR="$SYSROOT/Core"
    CURL_CONFIG="true"
    CURL_LDFLAGS="-L$SYSROOT/Core/LibKit -lcurl -lssl -lcrypto -lz -lnghttp2"
    OPENSSLDIR="$SYSROOT/Core/Config/ssl"
    OPENSSL_LINK="-L$SYSROOT/Core/LibKit -lssl -lcrypto"
)

configure() {
    cd "$SRC"
    if [ ! -d "git-src" ]; then
        git clone "$REPOSITORY" --branch "v$VERSION" --depth 1 git-src
    fi
}

build() {
    cd "$SRC/git-src"
    make -j"$JOBS" V=1 "${GIT_MAKE_ARGS[@]}"
}

install() {
    cd "$SRC/git-src"
    make install "${GIT_MAKE_ARGS[@]}" DESTDIR="$OUTPUT"
}
