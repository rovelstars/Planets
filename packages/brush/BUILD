FROM rust:latest

RUN git clone {{repository}} --branch {{branch}} --depth 1 /{{name}}

WORKDIR /{{name}}

RUN mkdir -p /output/{{name}}
RUN cargo install --locked --path brush-shell --root /output/{{name}}

# Link brush to sh, so other tools can use it as a shell
RUN ln -s /output/{{name}}/bin/brush /output/{{name}}/bin/sh

RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/{{name}} .

VOLUME ["/share"]