#!/bin/bash
# GNU Bash as the robust /bin/sh for the RunixOS build environment.
#
# Built native-in-chroot (NOT cross): the build runs chroot'd into the sysroot
# and a runixos ELF executes there, so configure runs its probes for real (no
# guessed cross defaults) and Bash's build-time helper programs (mksignames,
# mkbuiltins, ...) are compiled with our clang and run in place. This avoids the
# host-gcc path entirely - host gcc emits zlib-compressed debug sections that our
# lld (built without zlib) cannot link. CC_FOR_BUILD is our clang for the same
# reason. Installs bash + a /Core/Bin/sh symlink; the sandbox links /bin/sh here
# for self-hosted builds.

configure() {
    cd "$SRC"
    if [ ! -d "bash-$VERSION" ]; then
        curl -L "$REPOSITORY/bash-$VERSION.tar.gz" -o bash.tar.gz
        tar --no-same-owner -xf bash.tar.gz
    fi
    cd "bash-$VERSION"

    # -Wno-implicit-function-declaration: Bash's bundled termcap (tparam.c) calls
    # write() without including unistd.h; modern clang makes implicit declarations
    # a hard error, so downgrade it.
    CLANG="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT -Wno-implicit-function-declaration"
    CC="$CLANG" \
    CC_FOR_BUILD="$CLANG" \
    ./configure \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --without-bash-malloc \
        --disable-nls
}

build() {
    cd "$SRC/bash-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/bash-$VERSION"
    make install DESTDIR="$OUTPUT"
    ln -sfn bash "$OUTPUT/Core/Bin/sh"
}
