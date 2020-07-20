#!/bin/sh

if [ -z "$MODULE_NAME" ]; then
  # Register all modules from provided platform-complete.json list
  cat ./platform-complete.json | while read id ; do
    export MODULE_NAME=${id}
    ./create-deploy.sh
  done
elif [ "$MODULE_NAME" == "platform-complete" ]; then
  # Register UI modules from provided stripes.json list
  cat ./stripes.json | while read id ; do
    export MODULE_NAME=${id}
    ./create-deploy.sh
  done
else
  ./create-deploy.sh
fi
