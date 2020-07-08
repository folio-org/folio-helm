#!/bin/sh

if [ -z "$MODULE_NAME" ]
then
  # Register all modules from provided list
  cat ./platform-complete.json | while read id ; do
    export MODULE_NAME=${id}
    ./create-deploy.sh
  done
else
  ./create-deploy.sh
fi
