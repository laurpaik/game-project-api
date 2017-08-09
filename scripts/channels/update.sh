#!/bin/bash

API="${API_ORIGIN:-http://localhost:4741}"
URL_PATH="/channels/${ID}"
curl "${API}${URL_PATH}" \
  --include \
  --request PATCH \
  --header "Content-Type: application/json" \
  --header "Authorization: Token token=$TOKEN" \
  --data '{
    "channel": {
      "name": "'"${NAME}"'"
    }
  }'

   #\
  # --header "Authorization: Token token=$TOKEN"

echo
