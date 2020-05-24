#!/bin/sh

set -e

# Secret names should be of the format:
#    secret://projects/my-project/secrets/my-secret/versions/123

secret_prefix="secret://"

for v in $(printenv | grep ${secret_prefix}); do
  key=${v%"="*}   # e.g.) my-secret
  value=${v#*"="} # e.g.) secret://projects/my-project/secrets/my-secret/versions/123

  if echo "${value}" | grep -qv "^${secret_prefix}"; then
    continue # Skip the values that don't have the secret prefix.
  fi

  value=${value#"$secret_prefix"*} # Trim secret prefix. e.g.) projects/my-project/secrets/my-secret/versions/123

  project=$(echo "${value}" | cut -d '/' -f 2)
  secret=$(echo "${value}" | cut -d '/' -f 4)
  version=$(echo "${value}" | cut -d '/' -f 6)

  plaintext="$(gcloud secrets versions access "${version}" --secret="${secret}" --project="${project}")"
  export "${key}"="${plaintext}"
done
