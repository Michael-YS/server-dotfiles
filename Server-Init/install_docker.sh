#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"
require_root

# Add Docker's official GPG key:
# ca-certificates and curl are installed by install_packages.sh before this
# stage. Keep the standalone script usable as well.
if [[ "${SKIP_APT_UPDATE:-0}" != "1" ]]; then
    apt-get update -y
    pkg_install ca-certificates curl
fi
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update -y

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
