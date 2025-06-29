FROM rust:latest

# Set environment variables for non-interactive apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and kernel-specific dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    flex \
    bison \
    libssl-dev \
    libelf-dev \
    libncurses-dev \
    bc \
    rsync \
    kmod \
    pahole \
    initramfs-tools
    
# Clean up apt caches to keep the image size down
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /{{name}} && \
    mkdir -p /output
# Download and extract Linux kernel source
# Using wget and tar here; you could also clone a git repo if preferred
RUN wget -qO- {{source}} | tar -Jx --strip-components=1 -C /{{name}}

WORKDIR /{{name}}

ENV KBUILD_BUILD_HOST="{{build_host}}"
ENV KBUILD_BUILD_USER="{{build_user}}"

# Set up a default kernel configuration.
RUN make defconfig

# You can modify .config here if needed. For example:
# RUN sed -i 's/# CONFIG_DEBUG_INFO_DWARF4 is not set/CONFIG_DEBUG_INFO_DWARF4=y/' .config

# Compile the kernel and modules
# Use -j$(nproc) to leverage all available CPU cores in the container
RUN make -j$(nproc) bzImage modules

RUN make install INSTALL_PATH=/output/kernel
RUN make modules_install INSTALL_MOD_PATH=/output/modules

# Archive the output files from /output/kernel and /output/modules to a tarball present in /output
RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output kernel modules

# Copy License to /LICENSES
RUN mkdir -p /LICENSES && \
  cp -r /{{name}}/COPYING* /LICENSES/

# Create a share directory for output to be moved to during docker run.
VOLUME ["/share"]