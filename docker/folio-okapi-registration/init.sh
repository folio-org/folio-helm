#!/bin/sh

if [ -z "$MODULE_NAME" ]; then
  # Register all modules from provided Platform-complete list
  cat ./platform-complete.json | while read id ; do
    export MODULE_NAME=${id}
    ./create-deploy.sh
  done
elif [ "$MODULE_NAME" == "deployStripes" ]; then
  cat ./stripes.json | while read id ; do
    export MODULE_NAME=${id}
    ./create-deploy.sh
  done
else
  ./create-deploy.sh
fi
