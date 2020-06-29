#!/bin/bash

set -o errexit
set -o pipefail

project_root_dir="$(git rev-parse --show-toplevel)"
# shellcheck source=../lib/lib.sh
source "${project_root_dir}/lib/lib.sh"

readonly GITHUB_API="https://api.github.com"

usage() {
  cat <<EOF

  $(basename "${0}") clones Git repositories hosted in GitHub in bulk. Supports x-motemen/ghq.

  Usage:
      $(basename "${0}") OWNER

  Environment Variables
      GITHUB_TOKEN: A GitHub token to use GitHub API.

  Example:
      To clone all micnncim's repositories:
        $ $(basename "${0}") micnncim
EOF
}

check_executables() {
  # Confirm whether git is installed or not
  if ! type git &>/dev/null; then
    log::error "git is not installed"
    exit 1
  fi

  # Confirm whether jq is installed or not
  if ! type jq &>/dev/null; then
    log::error "jq is not installed"
    exit 1
  fi
}

clone_repos() {
  SECONDS=0
  page=1

  while [[ SECONDS -lt 300 ]]; do # timeout after 5m
    resp=$(curl -sL "${GITHUB_API}/users/${owner}/repos?type=sources&page=${page}")

    if [[ $(echo "${resp}" | jq '. | length') -eq 0 ]]; then
      exit 0
    fi

    urls=$(echo "${resp}" | jq -r '.[].html_url')

    for url in $urls; do
      log::info "Cloning ${url#'https://github.com/'}..."

      if type ghq &>/dev/null; then
        ghq get "${url}"
      else
        git clone "${url}"
      fi
    done

    page=$((page + 1))
  done

  log::error "execution timeout"
}

main() {
  owner=$1
  if [[ -z "${owner}" ]]; then
    log::error "missing argument: owner"
    usage
    exit 1
  fi

  util::ask "Trying to clone ${owner}'s all the repostories. Proceed?" || exit 0
  check_executables
  clone_repos
}

main "$@"
