FROM rust:latest

# Copy Patches

COPY /patches /patches/

RUN git clone {{repository}} --branch {{version}} --depth 1 /{{name}}

WORKDIR /{{name}}

# Apply patches if custom_uname_o is set in meta.toml. it is a boolean value, use it as {{custom_uname_o}}
RUN if [ "{{custom_uname_o}}" = "true" ]; then \
    patch crates/nu-command/src/system/uname.rs < /patches/uname_o.diff; \
  fi

RUN mkdir -p /output/{{name}}
RUN cargo install --path . --root /output/{{name}}
RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/{{name}} .

VOLUME ["/share"]