#!/bin/bash
source $(dirname $0)/environment.sh
curl -s localhost:8000/v2/models/$MODEL_NAME/stats | jq
