#!/bin/bash

SERVER="127.0.0.1:8001"

curl -s $SERVER/api #| jq -r '[.groups | .[].name] | join(" ")'

# APIS=$(curl -s $SERVER/apis | jq -r '[.groups | .[].name] | join(" ")')

# # do core resources first, which are at a separate api location
# api="core"
# curl -s $SERVER/api/v1 | jq -r --arg api "$api" '.resources | .[] | "\($api) \(.name): \(.verbs | join(" "))"'

# # now do non-core resources
# for api in $APIS; do
#     version=$(curl -s $SERVER/apis/$api | jq -r '.preferredVersion.version')
#     curl -s $SERVER/apis/$api/$version | jq -r --arg api "$api" '.resources | .[]? | "\($api) \(.name): \(.verbs | join(" "))"'
# done