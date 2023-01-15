#!/bin/bash

set -euo pipefail

function bash_alias() {
  echo "Setting up bash_alias"

  cp "${HOME}/.dotfiles/.bash_aliases" "${HOME}/.bash_aliases"
}

function docker_config_setup() {
  if [ -n "${DOCKER_CONFIG_BASE64-}" ]; then
    echo "Setting up Docker registries"

    mkdir -p "${HOME}/.docker"

    DOCKER_CONFIG="${HOME}/.docker/config.json"

    if [ -f "${DOCKER_CONFIG}" ]; then
      echo "Merging Docker config files"

      mv "${DOCKER_CONFIG}" "${DOCKER_CONFIG}.old"
      echo "${DOCKER_CONFIG_BASE64}" | base64 -d > "${DOCKER_CONFIG}.new"

      jq -s '.[0] * .[1]' "${DOCKER_CONFIG}.old" "${DOCKER_CONFIG}.new" > "${DOCKER_CONFIG}"
    else
      echo "Creating Docker config file"
      echo "${DOCKER_CONFIG_BASE64}" | base64 -d > "${DOCKER_CONFIG}"
    fi
  fi
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

  if command npm; then
    # @link https://github.com/so-fancy/diff-so-fancy
    # This may legitimately fail
    echo "Git: Installing Diff So Fancy"
    npm install -g diff-so-fancy
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
  fi
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
    echo "KUBECONFIG_BASE64 successfully converted into Kubernetes config"
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

bash_alias || (echo "bash_alias job failed and exited" && exit 1)
ssh_key || (echo "ssh_key job failed and exited" && exit 1)
kubeconfig || (echo "kubeconfig job failed and exited" && exit 1)
docker_config_setup || (echo "docker_config_setup failed and exited" && exit 1)
git_setup || echo "git_setup job failed and continued"
