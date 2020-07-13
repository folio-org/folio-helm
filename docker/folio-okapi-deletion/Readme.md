## Build Docker image

`docker build -t folio-okapi-deletion .`

### Linux console run command

`docker run --rm --name folio-okapi-deletion -e TENANT_ID=diku -e OKAPI_URL=http://okapi:9130 -e MODULE_NAME=mod-calendar folio-okapi-deletion`

## Alternative runnig image without compiling

`docker run --rm --name folio-okapi-deletion -e TENANT_ID=diku -e OKAPI_URL=http://okapi:9130 -e MODULE_NAME=mod-calendar docker.dev.folio.org/folio-okapi-deletion`

## Environment variables

When you deploy the `folio-okapi-deletion` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line.

### MODULE_NAME

The name of the module. Defaults to ``. If empty script does register all modules from `platform-complete.json` file.
If `deployStripes` script register all UI modules.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://okapi:9130`.

### TENANT_ID

The short name of the Tenant. Defaults to `diku`.

### PURGE_DATA

Purge module data. Defaults to `true`.
