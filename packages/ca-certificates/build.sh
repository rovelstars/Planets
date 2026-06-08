#!/bin/bash
# CA certificate bundle for RunixOS TLS.
#
# RunixOS openssl/curl/git read their trust store from OPENSSLDIR
# (/Core/Config/ssl): the CAfile is cert.pem. Without it, every https
# connection fails to verify ("unable to get local issuer certificate").
#
# This ships the Mozilla CA bundle. For now it sources the host's trusted
# bundle (the build host already trusts it); a future version should vendor a
# pinned Mozilla bundle (curl.se/ca/cacert.pem) for full reproducibility.

configure() { :; }
build() { :; }

install() {
    mkdir -p "$OUTPUT/Core/Config/ssl/certs"
    local found=""
    for src in \
        /etc/ssl/certs/ca-certificates.crt \
        /etc/pki/tls/certs/ca-bundle.crt \
        /etc/ca-certificates/extracted/tls-ca-bundle.pem \
        /etc/ssl/cert.pem \
        /Core/Config/ssl/cert.pem; do
        if [ -f "$src" ]; then
            cp "$src" "$OUTPUT/Core/Config/ssl/cert.pem"
            found="$src"
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "Error: no host CA bundle found to seed /Core/Config/ssl/cert.pem"
        exit 1
    fi
    echo "Installed CA bundle from $found"
}
