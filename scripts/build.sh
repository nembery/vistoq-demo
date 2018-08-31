#!/bin/bash
set -e

echo $GCLOUD_SERVICE_KEY | base64 -d > /root/gcloud-service-key.json

#
# base.sh DIR TARGET BASE_NAME
DIR="$1"
NAME="$2"
BASE_NAME="$3"
if [[ -z "$DIR" ]]; then
    echo "please specify the directory as first runtime argument"
    exit 1
fi
if [[ -z "$NAME" ]]; then
    echo "please specify the name as second runtime argument"
    exit 1
fi

SHA=$(git ls-tree HEAD "$DIR" | cut -d" " -f3 | cut -f1)
#TAG_EXISTS=$(tag_exists $SHA)

#if [ "$TAG_EXISTS" = "false" ]; then
packer build --force ${DIR}/$NAME.json
#else
#    touch manifest-${NAME}.json
#fi