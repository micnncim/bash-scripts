#!/bin/bash

set -o errexit
set -o pipefail

project_root_dir="$(git rev-parse --show-toplevel)"
# shellcheck source=../lib/lib.sh
# shellcheck disable=SC1091
source "${project_root_dir}/lib/lib.sh"

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
  tools=(git jq)
  for tool in "${tools[@]}"; do
    util::check_executable "${tool}"
  done
}

clone_repos() {
  owner=$1

  for url in $(gh api --paginate "users/${owner}/repos?sort=updated&direction=desc" | jq -r '.[].html_url'); do
    log::info "Cloning ${url#'https://github.com/'}..."

    if type ghq &>/dev/null; then
      ghq get -u -s "${url}" || true
    else
      git clone --quiet "${url}" || true
    fi
  done
}

main() {
  owner=$1
  if [[ -z "${owner}" ]]; then
    log::error "missing argument: owner"
    usage
    exit 1
  fi

  check_executables

  util::ask "Trying to clone ${owner}'s all the repostories. Proceed?" || exit 0

  clone_repos "${owner}"
}

main "$@"
