#!/bin/bash

readonly ESC=$(printf '\033')
readonly RED="${ESC}[31m"
readonly BLUE="${ESC}[34m"
readonly NO_COLOR="${ESC}[m"

readonly GITHUB_API="https://api.github.com"

owner=$1
if [[ -z "${owner}" ]]; then
  error "missing argument: owner"
  usage
  exit 1
fi

info() {
  echo "${BLUE}$(date +'%Y-%m-%dT%H:%M:%S%z')  INFO $*${NO_COLOR}" >&2
}

error() {
  echo "${RED}$(date +'%Y-%m-%dT%H:%M:%S%z') ERROR $*${NO_COLOR}" >&2
}

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
    error "git is not installed"
    exit 1
  fi

  # Confirm whether jq is installed or not
  if ! type jq &>/dev/null; then
    error "jq is not installed"
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
      info "Cloning ${url#'https://github.com/'}..."

      if type ghq &>/dev/null; then
        ghq get "${url}"
      else
        git clone "${url}"
      fi
    done

    page=$((page + 1))
  done

  error "execution timeout"
}

main() {
  check_executables
  clone_repos
}

main "$@"
