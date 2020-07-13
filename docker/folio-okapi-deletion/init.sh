#!/bin/sh

if [ -z "$MODULE_NAME" ]; then
  # Register all modules from provided Platform-complete list
  cat ./platform-complete.json | while read id ; do
    export MODULE_NAME=${id}
    ./delete-deploy.sh
  done
elif [ "$MODULE_NAME" == "deleteStripes" ]; then
  cat ./stripes.json | while read id ; do
    export MODULE_NAME=${id}
    ./delete-deploy.sh
  done
else
  ./delete-deploy.sh
fi
