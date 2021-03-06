## Build Docker image

`docker build -t folio-okapi-registration .`

### Linux console run command

`docker run --rm --name folio-okapi-registration -e TENANT_ID=diku -e OKAPI_URL=http://okapi:9130 -e MODULE_NAME=mod-calendar folio-okapi-registration`

## Alternative runnig image without compiling

`docker run --rm --name folio-okapi-registration -e TENANT_ID=diku -e OKAPI_URL=http://okapi:9130 -e MODULE_NAME=mod-calendar docker.dev.folio.org/folio-okapi-registration`

## Environment variables

When you deploy the `folio-okapi-registration` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line.

### MODULE_NAME

The name of the module. Defaults to ``. If empty script does register all modules from `platform-complete.json` file.
If `platform-complete` script register all UI modules.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://okapi:9130`.

### TENANT_ID

The short name of the Tenant. Defaults to `diku`. If blank, script does pass tenant creating and enabling steps.

### SAMPLE_DATA

Load module sample data. Defaults to `true`.

### REF_DATA

Load module reference data. Defaults to `true`.
