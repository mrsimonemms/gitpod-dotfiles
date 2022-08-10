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

  cp "${HOME}/.dotfiles/oh-my-zsh/zshrc" "${HOME}/.zshrc"
}

function ssh_key() {
  echo "Looking for a SSH_PRIVATE_KEY_BASE64 envvar"

  mkdir -p "${HOME}/.ssh"

  if [ -n "${SSH_PRIVATE_KEY_BASE64-}" ]; then
    echo "SSH_PRIVATE_KEY_BASE64 envvar found"

    echo "${SSH_PRIVATE_KEY_BASE64}" | base64 -d > "${HOME}/.ssh/id_rsa"
    chmod 600 "${HOME}/.ssh/id_rsa"
  fi

  if [ -n "${SSH_PUBLIC_KEY_BASE64-}" ]; then
    echo "SSH_PUBLIC_KEY_BASE64 envvar found"

    echo "${SSH_PUBLIC_KEY_BASE64}" | base64 -d > "${HOME}/.ssh/id_rsa.pub"
    chmod 600 "${HOME}/.ssh/id_rsa.pub"
  fi
}

kubeconfig
bash_alias
ssh_key
