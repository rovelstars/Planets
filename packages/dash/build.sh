#!/bin/bash
# DASH as the build-environment /bin/sh. Native-build-in-chroot (probes run for
# real). dash is the reference lean POSIX sh that autotools configure scripts are
# heavily tested against; brush stays the RunixOS user shell. Installs dash + a
# /Core/Bin/sh symlink.

configure() {
    cd "$SRC"
    if [ ! -d "dash-$VERSION" ]; then
        curl -L "$REPOSITORY/dash-$VERSION.tar.gz" -o dash.tar.gz
        tar --no-same-owner -xf dash.tar.gz
    fi
    cd "dash-$VERSION"

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --mandir=/Core/StoreRoom/Manual
}

build() {
    cd "$SRC/dash-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/dash-$VERSION"
    make install DESTDIR="$OUTPUT"
    ln -sfn dash "$OUTPUT/Core/Bin/sh"
}
