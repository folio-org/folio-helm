#!/bin/sh

echo ------------------ Enabling module for tenant ------------------
echo ------------------ $MODULE_ID
cat > /tmp/tenant-enable.json <<END
[{
  "id": "$MODULE_ID",
  "action" : "enable"
}]
END
curl -sL -w '\n' -D - -X POST -H "Content-type: application/json" -d @/tmp/tenant-enable.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?deploy=false\&preRelease=true\&tenantParameters=loadSample%3D$SAMPLE_DATA%2CloadReference%3D$REF_DATA

echo Done!
