#!/bin/bash

API="${API_ORIGIN:-http://localhost:4741}"
URL_PATH="/games/${ID}"
curl "${API}${URL_PATH}" \
  --include \
  --request PATCH \
  --header "Content-Type: application/json" \
  --header "Authorization: Token token=$TOKEN" \
  --data '{
    "game": {
      "cell": {
        "index": 2,
        "value": "x"
      },
      "over": false
    }
  }'
   #\
  # --header "Authorization: Token token=$TOKEN"

echo
