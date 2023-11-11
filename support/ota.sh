#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: $0 <ota zip>"
    exit 1
fi

ROM="$1"

METADATA=$(unzip -p "$ROM" META-INF/com/android/metadata)
SDK_LEVEL=$(echo "$METADATA" | grep post-sdk-level | cut -f2 -d '=')
TIMESTAMP=$(echo "$METADATA" | grep post-timestamp | cut -f2 -d '=')

FILENAME=$(basename $ROM)
DEVICE=$(echo $FILENAME | cut -f5 -d '-' | cut -f1 -d".")
ROMTYPE=$(echo $FILENAME | cut -f4 -d '-')
DATE=$(echo $FILENAME | cut -f3 -d '-')
ID=$(echo ${TIMESTAMP}${DEVICE}${SDK_LEVEL} | sha256sum | cut -f 1 -d ' ')
SIZE=$(du -b $ROM | cut -f1 -d '  ')
TYPE=$(echo $FILENAME | cut -f4 -d '-')
VERSION=$(echo $FILENAME | cut -f2 -d '-')
RELEASE_TAG=${DEVICE}_lineage-${VERSION}_${TIMESTAMP}

URL="https://......../${{FILENAME}"

response=$(jq -n --arg datetime $TIMESTAMP \
        --arg filename $FILENAME \
        --arg id $ID \
        --arg romtype $ROMTYPE \
        --arg size $SIZE \
        --arg url $URL \
        --arg version $VERSION \
        '$ARGS.named'
)
wrapped_response=$(jq -n --argjson response "[$response]" '$ARGS.named')
