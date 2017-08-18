#!/bin/bash

API="${API_ORIGIN:-http://localhost:4741}"
URL_PATH="/games"
curl "${API}${URL_PATH}" \
  --include \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Token token=$TOKEN" \
  --data '{
    "game": {
      "id": 4,
      "cells": ["","","","","","","","",""],
      "over":false,
      "player_x": {
        "id": 1,
        "email": "an@example.email"
        },
      "player_o": {
        "id": 2,
        "email":
        "another@example.email"
      }
    }
  }'
   #\
  # --header "Authorization: Token token=$TOKEN"

echo
