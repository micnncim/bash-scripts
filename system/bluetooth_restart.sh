#!/bin/bash

# From https://gist.github.com/thiagoghisi/50c3ba835ea72cdb0318fb3306fd2c76

set -o errexit
set -o pipefail

project_root_dir="$(git rev-parse --show-toplevel)"
# shellcheck source=../lib/lib.sh
# shellcheck disable=SC1091
source "${project_root_dir}/lib/lib.sh"

check_executables() {
  declare -r tools=(jq blueutil)
  for tool in "${tools[@]}"; do
    util::check_executable "${tool}"
  done
}

restart_bluetooth() {
  declare -a addresses
  while IFS='' read -r line; do addresses+=("$line"); done < <(blueutil --paired --format json | jq -r '.[] | select((.name != null) and (.connected == true))| .address')

  log::info 'Restarting bluetooth service...'
  blueutil -p 0 && sleep 1 && blueutil -p 1

  log::info 'Waiting bluetooth service to be restored...'
  until [[ $(blueutil -p) -eq 1 ]]; do sleep 1; done

  for address in "${addresses[@]}"; do
    # Trim leading and trailing spaces at the end
    # https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output
    local name
    name=$(blueutil --info "${address}" --format json | jq -r '.name' | awk '{$1=$1};1')

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
  done
}

main() {
  check_executables
  restart_bluetooth
}

main "$@"
