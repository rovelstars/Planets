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

# Set up a default kernel configuration.
# For simplicity, we'll use defconfig for your host architecture.
# For a custom kernel, you'd usually run `make menuconfig` interactively.
# Or copy a pre-existing .config file.
RUN make defconfig

# You can modify .config here if needed. For example:
# RUN sed -i 's/# CONFIG_DEBUG_INFO_DWARF4 is not set/CONFIG_DEBUG_INFO_DWARF4=y/' .config

# Compile the kernel and modules
# Use -j$(nproc) to leverage all available CPU cores in the container
RUN make -j$(nproc) bzImage modules

# Create a temporary directory for installing modules and headers
RUN mkdir -p /tmp/kernel-install
ENV INSTALL_PATH="/tmp/kernel-install"
ENV KBUILD_BUILD_HOST="{{build_host}}"
ENV KBUILD_BUILD_USER="{{build_user}}"

# Install modules to the temporary path
# Modules will be in /output/modules
RUN make modules_install INSTALL_MOD_PATH="/output/modules"

# Install the kernel image (bzImage) and System.map
RUN make install INSTALL_PATH="/output/kernel"

# Generate the initial RAM filesystem (initrd.img)
RUN update-initramfs -c -k "{{version}}" -b "/output/initramfs"

# Copy the compiled kernel image and initramfs to the /output volume
RUN cp "/{{name}}/boot/vmlinuz-{{version}}" "/output/" && \
  cp "/{{name}}/boot/initrd.img-{{version}}" "/output/" && \
  cp "/{{name}}/boot/System.map-{{version}}" "/output/" && \
  cp "/{{name}}/boot/config-{{version}}" "/output/"

# Create a share directory for output to be moved to during docker run.
VOLUME ["/share"]