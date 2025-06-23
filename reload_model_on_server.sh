
#!/bin/bash
source $(dirname $0)/environment.sh

wget -qO- \
 --header="Content-Type: application/json" \
 --post-data="" \
 localhost:8000/v2/repository/models/$MODEL_NAME/load
