#!/bin/bash

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

GITHUB_API="https://api.github.com"

cmd='ghq get'

# Confirm whether ghq is installed or not
if ! type ghq &>/dev/null; then
  echo "[INFO] x-motemen/ghq is not installed. git will be used instead"
  cmd='git clone'
  exit 1
fi

# Confirm whether git is installed or not
if ! type git &>/dev/null; then
  echo "[ERROR] git is not installed"
  exit 1
fi

# Confirm whether jq is installed or not
if ! type jq &>/dev/null; then
  echo "[ERROR] jq is not installed"
  exit 1
fi

owner=$1
if [[ -z "${owner}" ]]; then
  echo "[ERROR] missing owner" >&2
  usage
  exit 1
fi

SECONDS=0
page=1

while [[ SECONDS -lt 300 ]]; do # timeout after 5m
  resp=$(curl -sL "${GITHUB_API}/users/${owner}/repos?type=sources&page=${page}")

  if [[ $(echo "${resp}" | jq '. | length') -eq 0 ]]; then
    exit 0
  fi

  urls=$(echo "${resp}" | jq -r '.[].html_url')

  for url in $urls; do
    eval "${cmd} ${url}"
  done

  page=$((page + 1))
done

echo "[ERROR] execution timeout"
