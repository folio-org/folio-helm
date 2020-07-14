#!/bin/sh

echo ------------------ [$MODULE_NAME] Getting version ------------------
MODULE_NAME_VERSION=$(curl -s -S -w'\n' $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules?filter=$MODULE_NAME|  jq -r '.[0].id');

echo ------------------ [$MODULE_NAME_VERSION] Disabling module for tenant ------------------
cat > /tmp/tenant-disable.json <<END
[{
  "id": "$MODULE_NAME_VERSION",
  "action" : "disable"
}]
END
curl -sL -X DELETE -D - -w '\n' $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules/$MODULE_NAME_VERSION

echo Done!
