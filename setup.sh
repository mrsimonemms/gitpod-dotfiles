#!/bin/bash

set -euo pipefail

function bash_alias() {
  echo "Setting up bash_alias"

  cp "${HOME}/.dotfiles/.bash_aliases" "${HOME}/.bash_aliases"
}

function git_setup() {
  echo "Setting up Git"

  echo "Git: Configuring aliases"
  git config --global alias.cp cherry-pick
  git config --global alias.co checkout
  git config --global alias.ci commit
  git config --global alias.st status

  echo "Git: Use rebase to pull"
  git config --global pull.rebase true

  if [ -n "${GPG_PRIVATE_KEY_BASE64-}" ]; then
    echo "Git: Installing GPG key"
    gpg --verbose --batch --import <(echo "${GPG_PRIVATE_KEY_BASE64}" | base64 -d)
    echo 'pinentry-mode loopback' >> ~/.gnupg/gpg.conf
    git config --global user.signingkey "${GPG_SIGNING_KEY}"
    git config --global commit.gpgsign true
  fi

  # @link https://github.com/so-fancy/diff-so-fancy
  # This may legitimately fail
  echo "Git: Installing Diff So Fancy"
  npm install -g diff-so-fancy
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  git config --global interactive.diffFilter "diff-so-fancy --patch"
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
git_setup || echo "Failed to do the Git setup"
