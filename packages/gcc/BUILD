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

RUN git clone --depth 1 --branch {{branch}} {{repository}} /{{name}} 

WORKDIR /{{name}}

# Download prerequisites
RUN ./contrib/download_prerequisites

# Build and install
RUN mkdir /tmp/build && cd /tmp/build
RUN /{{name}}/configure --prefix=/output/{{name}} --disable-multilib --enable-languages=c,c++
# Limit the number of jobs to half the number of available processors
# to avoid overwhelming the system and ensure a smoother build process
RUN make -j$(nproc --all) -l $(nproc --all)/2
RUN make install

# Compress the output
RUN cd /output && \
  tar -czf {{name}}-{{version}}.tar.gz -C gcc .

# Copy all licenses inside gcc source to /LICENSES
RUN mkdir -p /LICENSES && \
  cp -r /{{name}}/COPYING* /LICENSES/

VOLUME ["/share"]