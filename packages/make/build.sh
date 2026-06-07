#!/bin/bash
# Build script for GNU Make (RunixOS native, cross-compiled).
#
# This is the autotools cross template the rest of the GNU build-env tools
# (sed/grep/gawk/tar/gzip/xz/diffutils/patch/m4) reuse. Key points:
#  - CC is our cross clang with --target=x86_64-rovelstars-linux-runixos so the
#    produced binary is a native RunixOS ELF (interpreter /Core/LibKit/ld-runixos).
#  - The autotools --host triple is x86_64-rovelstars-linux-gnu, NOT the clang
#    target: config.sub rejects an unknown os "runixos", and RunixOS is glibc +
#    Linux ABI so "linux-gnu" is the correct autotools host. --host != --build
#    flips configure into cross mode.
#  - Install layout (Bin/LibKit/APIHeader) is set explicitly; CONFIG_SITE (from
#    the sandbox) supplies datadir/man/libexec/etc as StoreRoom/LibKit.

configure() {
    cd "$SRC"
    if [ ! -d "make-$VERSION" ]; then
        curl -L "$REPOSITORY/make-$VERSION.tar.gz" -o make.tar.gz
        tar xf make.tar.gz
    fi
    cd "make-$VERSION"

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --build="$(./config.guess)" \
        --host=x86_64-rovelstars-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --without-guile \
        --disable-nls
}

build() {
    cd "$SRC/make-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/make-$VERSION"
    make install DESTDIR="$OUTPUT"
}
