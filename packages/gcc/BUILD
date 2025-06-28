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
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PREFIX=/output/{{name}}
ENV MAKEFLAGS=-j$(nproc)

RUN git clone --depth 1 --branch {{branch}} {{repository}} /{{name}} 

WORKDIR /{{name}}

# Download prerequisites
RUN ./contrib/download_prerequisites

# Build and install
RUN mkdir /tmp/build && cd /tmp/build && \
  /{{name}}/configure --prefix=$PREFIX --disable-multilib --enable-languages=c,c++ && \
  make && \
  make install

# Compress the output
RUN cd /output && \
  tar -czf {{NAME}}-{{VERSION}}.tar.gz -C gcc .

# Copy all licenses inside gcc source to /LICENSES
RUN mkdir -p /LICENSES && \
  cp -r /{{name}}/COPYING* /{{name}}/COPYING3* /{{name}}/COPYING.RUNTIME* /{{name}}/COPYING.RUNTIME.GPL3* /{{name}}/COPYING.RUNTIME.LGPL3* /LICENSES/

VOLUME ["/share"]