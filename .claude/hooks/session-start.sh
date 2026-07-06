#!/bin/bash
# SessionStart hook for Claude Code on the web.
#
# Installs a Swift 6.1.2 Linux toolchain and warms the linux-test-harness
# build so `swift test` works from the first turn of every session. The
# container state is cached after the hook completes, so the expensive
# install only happens on the first session (or after a cache eviction);
# cached sessions fall through the idempotency checks in seconds.
set -euo pipefail

# Only needed in remote (web) sessions; local machines manage their own Swift.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SWIFT_VERSION="6.1.2"
INSTALL_DIR="/opt/swift-${SWIFT_VERSION}"
SWIFT_BIN="${INSTALL_DIR}/usr/bin"

install_from_swift_org() {
  # Preferred source, but blocked (403) by some org egress policies.
  local url="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2404/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu24.04.tar.gz"
  local tarball="/tmp/swift-toolchain.tar.gz"
  curl -fsSL --connect-timeout 10 -o "$tarball" "$url" || return 1
  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tarball" --strip-components=1 -C "$INSTALL_DIR"
  rm -f "$tarball"
}

install_from_gcr_mirror() {
  # Fallback: extract the official swift:<version>-noble Docker image rootfs
  # layer-by-layer from Google's Docker Hub mirror (anonymous pulls allowed).
  # The host is Ubuntu 24.04 (noble), so the image's binaries run natively.
  local repo="library/swift" tag="${SWIFT_VERSION}-noble"
  local registry="https://mirror.gcr.io/v2"
  local accept_index="application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.index.v1+json"
  local accept_manifest="application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json"

  local digest
  digest=$(curl -fsSL -H "Accept: ${accept_index}" "${registry}/${repo}/manifests/${tag}" \
    | jq -r '.manifests[] | select(.platform.architecture=="amd64" and .platform.os=="linux") | .digest' | head -1)
  [ -n "$digest" ] || return 1

  local layers
  layers=$(curl -fsSL -H "Accept: ${accept_manifest}" "${registry}/${repo}/manifests/${digest}" \
    | jq -r '.layers[].digest')
  [ -n "$layers" ] || return 1

  mkdir -p "$INSTALL_DIR"
  local layer blob="/tmp/swift-layer.tar.gz"
  for layer in $layers; do
    curl -fsSL -o "$blob" "${registry}/${repo}/blobs/${layer}"
    # Verify content digest before extracting.
    echo "${layer#sha256:}  ${blob}" | sha256sum -c --quiet -
    tar -xzf "$blob" -C "$INSTALL_DIR"
    rm -f "$blob"
  done
}

if ! "${SWIFT_BIN}/swift" --version >/dev/null 2>&1; then
  echo "Installing Swift ${SWIFT_VERSION} toolchain..."
  install_from_swift_org || {
    echo "download.swift.org unavailable (likely egress policy); using mirror.gcr.io image layers..."
    rm -rf "$INSTALL_DIR"
    install_from_gcr_mirror
  }
  "${SWIFT_BIN}/swift" --version
fi

# Runtime libraries the toolchain needs on a bare Ubuntu 24.04 host.
REQUIRED_PKGS="libcurl4t64 libxml2 libncurses6 libedit2 libsqlite3-0 libz3-4"
MISSING_PKGS=""
for pkg in $REQUIRED_PKGS; do
  dpkg -s "$pkg" >/dev/null 2>&1 || MISSING_PKGS="$MISSING_PKGS $pkg"
done
if [ -n "$MISSING_PKGS" ]; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $MISSING_PKGS
fi

# Put swift on PATH for the whole session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"${SWIFT_BIN}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Warm the harness: resolve swift-cidr and compile app sources + tests so the
# first `swift test` of the session is instant. Non-fatal — a mid-migration
# compile error in app code shouldn't block the session from starting.
HARNESS_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/linux-test-harness"
if [ -d "$HARNESS_DIR" ]; then
  (cd "$HARNESS_DIR" && "${SWIFT_BIN}/swift" build --build-tests) \
    || echo "WARNING: harness pre-build failed; 'swift test' will surface the details"
fi

echo "Swift toolchain ready: ${SWIFT_BIN}"
