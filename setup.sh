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

    mkdir -p "${HOME}/.kube"
    echo "${KUBECONFIG_BASE64}" | base64 -d > "${HOME}/.kube/config"
    chmod 600 "${HOME}/.kube/config"
  fi
}

kubeconfig
bash_alias
