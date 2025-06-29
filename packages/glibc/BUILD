FROM rust:latest

# Install required build dependencies
RUN apt-get update && \
  apt-get install -y \
    git \
    build-essential \
    flex \
    bison \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    texinfo \
    wget \
    xz-utils \
    python3 \
    gawk \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch {{branch}} {{repository}} /{{name}} 

WORKDIR /{{name}}
ENV PREFIX=/output/{{name}}

# Compile in /tmp/build
RUN mkdir -p /tmp/build
WORKDIR /tmp/build
RUN /{{name}}/configure --prefix=$PREFIX/usr \
      #--with-headers=$PREFIX/usr/include \ ---- TODO: look into this line, modify it to use the correct headers when we use custom Docker image base - based on our OS' rootfs.
      --with-bugurl=https://github.com/rovelstars/Planets/issues/new?title=BUG%3A%20glibc%20-%20 \
      --enable-bind-now \
      --enable-fortify-source \
      --enable-kernel={{minimum_kernel_version}} \
      --enable-multi-arch \
      --enable-stack-protector=strong \
      --disable-nscd \
      --disable-profile \
      --disable-werror

RUN make -j$(nproc --all) -l $(nproc --all)/2

RUN make install

# Compress the output
RUN cd /output && \
  tar -czf {{name}}-{{version}}.tar.gz -C {{name}} .

# Copy all licenses inside source to /LICENSES
RUN mkdir -p /LICENSES && \
  cp -r /{{name}}/COPYING* /LICENSES/

VOLUME ["/share"]