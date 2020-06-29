#!/bin/bash

set -o errexit
set -o pipefail

project_root_dir="$(git rev-parse --show-toplevel)"
# shellcheck source=../lib/lib.sh
source "${project_root_dir}/lib/lib.sh"

export GITHUB_TOKEN='' # Override GitHub user

readonly git_username=''
readonly git_email=''

readonly branch=''

fetch_github_actor() {
  gh api graphql -f query='
query {
   viewer {
    login
 }
}' | jq -r '.data.viewer.login'
}

main() {
  echo "Author of PR: $(fetch_github_actor)"
  util::ask 'Continue?'

  git switch master
  git pull origin master

  git switch -c "${branch}"
  git add .
  git -c user.name="${git_username}" -c user.email="${git_email}" commit -m ''

  gh pr create \
    --title '' \
    --body '' \
    --assignee '' \
    --label '' \
    --milestone ''
}

main "$@"
