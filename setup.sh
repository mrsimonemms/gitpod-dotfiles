#!/bin/bash

set -euo pipefail

function bash_alias() {
  echo "Setting up bash_alias"

  cp "${HOME}/.dotfiles/.bash_aliases" "${HOME}/.bash_aliases"
}

function kubeconfig() {
  echo "Looking for a KUBECONFIG_BASE64 envvar"

  if [ -n "${KUBECONFIG_BASE64-}" ]; then
    echo "KUBECONFIG_BASE64 envvar found"

    KUBECONFIG="${HOME}/.kube/config"

    mkdir -p "${HOME}/.kube"
    mv -f "${KUBECONFIG}" "${HOME}/.kube/config.orig" || true # Save the old kubeconfig
    echo "${KUBECONFIG_BASE64}" | base64 -d > "${KUBECONFIG}"
    chmod 600 "${KUBECONFIG}"
  fi
}

function ohmyzsh() {
  echo "Installing Oh My ZSH!"

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

kubeconfig
ohmyzsh
bash_alias
