#!/bin/bash

hide_outdated_comments() {
  local -r owner="${1}"
  local -r repo="${2}"
  local -r number="${3}"
  local -r user="${4}"
  local -r header="${5:-}"

  local -r node_ids=$(gh api "/repos/${owner}/${repo}/issues/${number}/comments" | jq ".[] | select(.user.login == \"$user\" and (.body | startswith(\"$header\"))) | .node_id")

  for id in $node_ids; do
    gh api graphql -f query="
    mutation {
      minimizeComment(input: {classifier: OUTDATED, subjectId: ${id}}) {
        minimizedComment {
          isMinimized
        }
      }
    }"
  done
}
