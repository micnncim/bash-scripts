#!/bin/bash

[[ -n $DEBUG ]] && set -x

set -o errexit
set -o pipefail

project_root_dir="$(git rev-parse --show-toplevel)"
# shellcheck source=../lib/lib.sh
# shellcheck disable=SC1091
source "${project_root_dir}/lib/lib.sh"

check_executables() {
  declare -r tools=(jq blueutil fzf)
  for tool in "${tools[@]}"; do
    util::check_executable "${tool}"
  done
}

select_device() {
  blueutil --recent --format json | jq -r '.[] | .name' | sort | uniq | fzf
}

connect_device() {
  local name="${1}"

  local -r address=$(blueutil --recent --format json | jq -r ".[] | select(.name == \"$name\") | .address")

  # https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output
  name=$(echo "${name}" | awk '{$1=$1};1')

  # If the device is already connected, skip to connect to it.
  if [[ $(blueutil --info "${address}" --format json | jq -r '.connected') = "true" ]]; then
    log::info "${name} is already connected"
    return 0
  fi

  # Retry at most 5 times
  local n=0
  until [[ "$n" -ge 5 ]]; do
    log::info "Trying to connect to ${name}..."

    blueutil --connect "${address}" >/dev/null 2>&1 &&
      log::info "Connected to ${name}" &&
      break

    log::warn "Failed to connect to ${name}"

    n=$((n + 1))
    sleep 1
  done
}

main() {
  check_executables
  connect_device "$(select_device)"
}

main "$@"
