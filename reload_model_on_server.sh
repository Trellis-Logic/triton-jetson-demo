
#!/bin/bash
source $(dirname $0)/environment.sh

 curl -X POST localhost:8000/v2/repository/models/$MODEL_NAME/load