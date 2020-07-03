#!/bin/bash

readonly ESC=$(printf '\033')
readonly RED="${ESC}[31m"
readonly YELLOW="${ESC}[33m"
readonly BLUE="${ESC}[34m"
readonly CYAN="${ESC}[36m"
readonly NO_COLOR="${ESC}[m"

#######################################
# Output colorized log at info level.
# Arguments:
#   $1: Message to log
# Outputs:
#   Output message to stderr
#######################################
log::info() {
  echo "${BLUE}$(date +'%Y-%m-%dT%H:%M:%S%z')  INFO $*${NO_COLOR}" >&2
}

#######################################
# Output colorized log at error level.
# Arguments:
#   $1: Message to log
# Outputs:
#   Output message to stderr
#######################################
log::error() {
  echo "${RED}$(date +'%Y-%m-%dT%H:%M:%S%z') ERROR $*${NO_COLOR}" >&2
}

#######################################
# Output colorized log at warning level.
# Arguments:
#   $1: Message to log
# Outputs:
#   Output message to stderr
#######################################
log::warn() {
  echo "${YELLOW}$(date +'%Y-%m-%dT%H:%M:%S%z')  WARN $*${NO_COLOR}" >&2
}

#######################################
# Output colorized log at debug level.
# Globals:
#   DEBUG
# Arguments:
#   $1: Message to log
# Outputs:
#   Output message to stderr if DEBUG == 'true'
#######################################
log::debug() {
  if [[ $DEBUG == 'true' ]]; then
    return 0
  fi
  echo "${CYAN}$(date +'%Y-%m-%dT%H:%M:%S%z') DEBUG $*${NO_COLOR}" >&2
}

#######################################
# Ask yes or no as interactive prompt.
# Arguments:
#   $1: Inquiry message
# Outputs:
#   Show inquiry prompt
# Returns:
#   0 if the answer is 'y', 1 if 'n'.
#######################################
util::ask() {
  while true; do
    read -r -p "${BLUE}$1 [Y/n] ${NO_COLOR}" answer
    case $answer in
      [Y]*)
        echo
        return 0
        ;;
      [n]*) return 1 ;;
      *) echo "${YELLOW}Please answer [Y/n].${NO_COLOR}" ;;
    esac
  done
}

#######################################
# Check existence of an executable.
# Arguments:
#   $1: Executable
# Outputs:
#   Show error message if the given executable doesn't exist
# Returns:
#   1 if the given executable doesn't exist, otherwise 0.
#######################################
util::check_executable() {
  if ! type "${1}" &>/dev/null; then
    log::error "${1} not found"
    return 1
  fi
}
