#!/bin/bash

export GITHUB_TOKEN='' # Override GitHub user

readonly git_username=''
readonly git_email=''

readonly branch=''

function ask() {
  while true; do
    read -r -p "Continue [Y/n]? " answer
    case $answer in
      [Y]*) return 0 ;;
      [n]*) exit 0 ;;
      *) echo "Please answer [Y/n]." ;;
    esac
  done
}

function fetch_github_actor() {
  gh api graphql -f query='
query {
   viewer {
    login
 }
}' | jq -r '.data.viewer.login'
}

function main() {
  echo "Author of PR: $(fetch_github_actor)"
  ask

  git pull origin master

  git switch master

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

main
