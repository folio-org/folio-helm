## Build Docker image

`docker build -t folio-okapi-registration .`

### Linux console run command

`docker run --rm -d --name folio-okapi-registration -h folio-okapi-registration -e TENANT_ID=diku -e OKAPI_URL=http://localhost:9130 -e MODULE_NAME=mod-calendar folio-okapi-registration`

### What to deploy


## Environment variables

When you deploy the `folio-okapi-registration` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line.

### MODULE_ID

The name of the module. Defaults to ``.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://okapi:9130`.
