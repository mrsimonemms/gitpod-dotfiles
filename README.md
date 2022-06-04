# Dotfiles

Common dotfiles for use with [Gitpod](https://www.gitpod.io/docs/config-dotfiles)

## Installation Scripts

### Kube config

If a `KUBECONFIG_BASE64` envvar is found, this will be decoded and saved
to `$HOME/.kube/config`. This must be a valid kubeconfig file that is base64
encoded.

## Scripts provided

These are installed as globally executable scripts.

### Gitpod Dev

Command: `gitpod-dev`

A series of useful commands for developing Gitpod.

### Gitpod Installer

Command: `gitpod-installer`

A Bash wrapper to use the Installer from a Docker binary. Set the version
with the `GITPOD_INSTALLER_VERSION` variable.
