#!/usr/bin/env bash

# fail fast
set -e

if [[ -n "$ATMOS_SECRET_BUCKET" && -n "$ATMOS_SECRET_KEYS" ]]; then
  # Gets the secret values from the list of secret keys in $ATMOS_SECRET_KEYS
  # The keys can be as-is and they will be upcased for the environment variable
  # name, otherwise you can supply the name for the environment variable like
  # envname=key

  for key in $ATMOS_SECRET_KEYS; do
    name=${key%%=*}
    s3_key=${key##*=}
    if [[ $name == $s3_key ]]; then
      name=${name^^}
    fi
    value=$(aws s3 cp s3://$ATMOS_SECRET_BUCKET/$s3_key -)
    declare -x "$name=$value"
  done

fi

exec "$@"
