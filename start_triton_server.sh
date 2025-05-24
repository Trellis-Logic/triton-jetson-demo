#!/bin/bash
set -e
source $(dirname $0)/environment.sh

/opt/tritonserver/bin/tritonserver --model-repository $TRITON_REPO_DIR --model-control-mode=explicit --load-model $MODEL_NAME --http-port=8000 --grpc-port=8001 --metrics-port=8002