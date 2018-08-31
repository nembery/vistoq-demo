#!/bin/bash
set -e

if [[ ! -f /root/gcloud-service-key.json ]]; then
    echo $GCLOUD_SERVICE_KEY | base64 -d > /root/gcloud-service-key.json
fi

#
# base.sh DIR TARGET BASE_NAME
DIR="$1"
NAME="$2"

if [[ -z "$DIR" ]]; then
    echo "please specify the directory as first runtime argument"
    exit 1
fi
if [[ -z "$NAME" ]]; then
    echo "please specify the name as second runtime argument"
    exit 1
fi

packer validate ${DIR}/$NAME.json
