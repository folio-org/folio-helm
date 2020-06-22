## Build Docker image

`docker build -t create-deploy .`

### Linux console run command

`docker run --rm -d --name folio-okapi-registration -h create-deploy -e TENANT_ID=mytenant -e OKAPI_URL=http://localhost:9130 -e MODULE_NAME=mod-calendar folio-okapi-registration`

### What to deploy

Update the included install/stripes-install.json and install/okapi-install.json files with the modules you wish to deploy to your Folio system's Okapi `/_/proxy/tenants/<tenant_id>/install` endpoint. The initial deploy will take some time, as all of the module descriptors are brought into your Okapi's `/_/proxy/modules` endpoint.

## Environment variables

When you deploy the `create-deploy` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant. Defaults to `mytenant`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://okapi:9130`.
