#!/bin/bash

SCRIPTS_DIR="$(dirname "$0")/www/scripts/"
CORDOVA_VERSION=`cat CORDOVA_VERSION`
DEVICE_MODEL=$1

if [ -z "$DEVICE_MODEL" ]; then
    echo "ERROR: Missing device model. $0 iOS|android"
    exit 1;
fi

DESTINATION="cordova-current.js"
FILENAME="cordova-$CORDOVA_VERSION-$DEVICE_MODEL.js"

if [ ! -f "$SCRIPTS_DIR$FILENAME" ]; then
    echo "ERROR: Missing file $FILENAME."
    exit 2;
fi

`cp $SCRIPTS_DIR$FILENAME $SCRIPTS_DIR$DESTINATION`
