FROM rust:latest

RUN apt install ninja-build cmake lld -y
RUN git clone {{repository}} --branch {{branch}} --depth 1 /{{name}}

WORKDIR /{{name}}

RUN mkdir -p /tmp/build
WORKDIR /tmp/build

RUN cmake /{{name}}/llvm -G Ninja \
  -DCLANG_INSTALL_PACKAGE_DIR=Core/LibKit/cmake/clang \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-Wno-error -Wno-aggressive-loop-optimizations" \
  -DCMAKE_INSTALL_BINDIR=Core/Bin \
  -DCMAKE_INSTALL_DATADIR=Core/StoreRoom \
  -DCMAKE_INSTALL_DATAROOTDIR=Core/StoreRoom \
  -DCMAKE_INSTALL_DOCDIR=Construct/StoreRoom/Docs \
  -DCMAKE_INSTALL_INCLUDEDIR=Core/APIHeader \
  -DCMAKE_INSTALL_INFODIR=Construct/StoreRoom/Info \
  -DCMAKE_INSTALL_LIBDIR=Core/LibKit \
  -DCMAKE_INSTALL_LIBEXECDIR=Core/LibKit \
  -DCLANG_RESOURCE_DIR=LibKit \
  -DLLD_INSTALL_PACKAGE_DIR=Core/LibKit/cmake/lld \
  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-rovelstars-linux" \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;libclc;lldb;openmp;" \
  -DLLVM_ENABLE_RUNTIMES="libunwind;libc;libcxxabi;compiler-rt;libcxx" \
  -DLLVM_ENABLE_WERROR=OFF \
  -DLLVM_INSTALL_PACKAGE_DIR=Core/LibKit/cmake/llvm \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_USE_LINKER=lld

RUN cmake --build .

cmake --build .

cmake -DCMAKE_INSTALL_PREFIX=/output -P cmake_install.cmake 

cmake /llvm/llvm -LA > /share/cmakeLA.txt