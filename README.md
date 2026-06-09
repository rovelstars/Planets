# Planets

Planets is the package list for **RunixOS** - the build recipes that
[Rocket](https://github.com/rovelstars/Rocket) builds into the OS. Each "planet"
is one package: a `meta.toml` plus a `build.sh`. Together these recipes build
all of RunixOS - its all-LLVM toolchain, its glibc/kernel-headers core, and its
entire userspace - and RunixOS builds them on itself (self-hosting).

We decide which planets ship in the official OS; ones that are not useful or do
not meet our standards are not included. Third-party planets can be installed
manually by users but are not part of the official build (more on those later).

## Package structure

```tree
package_name/
  meta.toml
  build.sh
  patches/ (optional)
    some_fix.patch
```

### meta.toml

```toml
name = "package_name"
version = "1.0.0"
description = "A brief description of the package"
licenses = ["MIT"]
repository = "https://github.com/example/repository"
branch = "" # optional, when tags don't match version or you need a branch
# local_path = "../../../fork" # optional, build a local fork working tree
dependencies = ["glibc"]      # build order is resolved from these
```

Any extra fields in `meta.toml` are passed as uppercase environment variables to
the build script. For example, `custom_uname_o = "true"` becomes `$CUSTOM_UNAME_O`.
If you add custom flags, write a short explanation in a `TIP.md` file.

### build.sh

Three shell functions Rocket calls in order:

```sh
configure() {
    # Clone source, run configure/cmake, etc.
    # Available vars: $SRC, $OUTPUT, $SYSROOT, $REPOSITORY, $VERSION, $BRANCH, $JOBS
}

build() {
    # Compile the package
}

install() {
    # Install to $OUTPUT in the RunixOS layout:
    # /Core/Bin, /Core/LibKit, /Core/APIHeader, /Core/StoreRoom, /Core/Config
}
```

RunixOS target triple: `x86_64-rovelstars-linux-runixos` (glibc + Linux ABI).
C packages compile with
`$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT`;
Rust packages `cargo build --target x86_64-rovelstars-linux-runixos`. Recipes
work both when cross-bootstrapping from a foreign host and under
`rocket build --self-hosted` (zero host tools, on RunixOS itself), so prefer the
sysroot's own tools and avoid hardcoded host paths.

## Packages

RunixOS is all-LLVM (clang/lld, no gcc/GNU binutils). The set builds the OS from
the toolchain up; almost all of it self-hosts.

| Group | Packages |
|-------|----------|
| Toolchain (host-bootstrap) | llvm, cmake, rust |
| Toolchain (native, self-hosting) | llvm-native, llvm21, cmake-native, rust-native, compiler-rt, llvm-runtimes |
| Core | kernel-headers, glibc-headers, glibc |
| Build env | make, ninja, bash, dash, m4, bison, sed, grep, gawk, diffutils, patch, gzip, xz, tar, rsync, patchelf, python, perl |
| Libraries | zlib, openssl, nghttp2, expat, ca-certificates |
| Userspace | coreutils, findutils, brush, nushell, helix, git, curl, fastfetch, aether, uac, rev |
| Meta | base-image (assembles the system image) |

The `*-native` toolchain packages run on RunixOS and let it rebuild itself; the
plain `llvm`/`cmake`/`rust` build host-runnable cross compilers used only to
bootstrap from a foreign host.

## Copyleft licenses

While we prefer non-copyleft licenses wherever possible, we respect developers'
choices to use copyleft licenses. Such projects must copy all relevant license
files to the `LICENSES` directory in the repo root, and reference the license
title in the planet's `meta.toml`. For example, for glibc:

```toml
licenses = ["GPL-2.0", "LGPL-2.1", "GCC RUNTIME LIBRARY EXCEPTION"]
```

License names should match the upstream license file titles. Copy the relevant
files (`COPYING`, `COPYING.LIB`, etc.) to `LICENSES`. Rocket includes them in the
final system at `/Core/Essence/Licenses/<package_name>/` for system packages and
`/Construct/Kits/Licenses/<package_name>/` for third-party apps.

## Naming

Package names in `meta.toml` should be lowercase with no special characters
except `_`. This keeps archive file names clean (`{{name}}-{{version}}.<format>`).

## Contributing

Follow the structure above. Prefer linking the upstream git repository in
`meta.toml`; if you must fork, document the original URL. Put patches in
`patches/` and add a `TIP.md` when the build setup is non-obvious.

**Note:** By contributing you agree to license your contributions under the same
license as the project (Apache License 2.0).

## Pros

- Recipes build **all of RunixOS from the toolchain up** -- LLVM, glibc/kernel
  headers, the build environment, and the full userspace.
- **Self-hosting**: almost every planet rebuilds on RunixOS itself with zero
  foreign tools, via Rocket's `--self-hosted` mode.
- Tiny, transparent recipes (`meta.toml` + `build.sh`); easy to read, patch, and
  audit; copyleft handled explicitly with bundled license files.

## Cons / tradeoffs

- Curated, **RunixOS-only** set -- third-party planets are manual and not part of
  the official build.
- Shell recipes (same tradeoff as Rocket): powerful but can hide
  non-reproducible or host-leaking steps.
- Source-built: no prebuilt binary packages, so a full build is heavy.

## Known issues / limitations

- **Self-host bootstrap not 100%.** The 2-stage bootstrap proves the toolchain +
  build environment, but a handful of core packages still have gaps building
  fully under self-host (tracked); cross-bootstrap from a host covers the rest.
- Some packages are oversized without tuning (e.g. git installs every `git-core`
  program as a full copy, ~780M, until `INSTALL_HARDLINKS` is applied).
- No version pinning/lockfile across planets; upstream drift can break a recipe.
- A few `*-native` toolchain recipes are newer and less battle-tested than the
  host-bootstrap ones.
