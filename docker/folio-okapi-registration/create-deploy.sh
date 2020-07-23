#!/bin/bash

echo ------------------ [$MODULE_NAME] Getting descriptor ------------------
curl -s -S -w'\n' 'http://folio-registry.aws.indexdata.com/_/proxy/modules?filter='$MODULE_NAME'&latest=1&full=true'| jq '.[0]' > /tmp/descriptor.json
MODULE_NAME_VERSION=$(curl -s -S -w'\n' 'http://folio-registry.aws.indexdata.com/_/proxy/modules?filter='$MODULE_NAME'&latest=1&full=true'| jq -r '.[0].id');

echo ------------------ [$MODULE_NAME_VERSION] Pushing module descriptor ------------------
curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" -d @/tmp/descriptor.json $OKAPI_URL/_/proxy/modules

echo ------------------ [$MODULE_NAME_VERSION] Pushing module deployment descriptor ------------------
DEPLOYMENT_JSON="{\"srvcId\":\"$MODULE_NAME_VERSION\",\"instId\":\"$MODULE_NAME_VERSION\",\"url\":\"http://$MODULE_NAME\"}"
curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" -d $DEPLOYMENT_JSON $OKAPI_URL/_/discovery/modules

if [ -n "$TENANT_ID" ]; then

  echo ------------------ [$MODULE_NAME_VERSION] Creating tenant ------------------
  TENANT_JSON="{\"id\":\"$TENANT_ID\",\"name\":\"$TENANT_ID\",\"description\":\"Default_tenant\"}"
  curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" -d $TENANT_JSON $OKAPI_URL/_/proxy/tenants

  echo ------------------ [$MODULE_NAME_VERSION] Enabling module for tenant ------------------
  TENANT_ENABLE_JSON="[{\"id\":\"$MODULE_NAME_VERSION\",\"action\":\"enable\"}]"
  curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" -d $TENANT_ENABLE_JSON $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?deploy=false\&preRelease=true\&tenantParameters=loadSample%3D$SAMPLE_DATA%2CloadReference%3D$REF_DATA

  echo ------------------ Upgrading modules ------------------
  curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" $OKAPI_URL/_/proxy/tenants/$TENANT_ID/upgrade

fi

echo Done!
