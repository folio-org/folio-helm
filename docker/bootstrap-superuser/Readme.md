## Build Docker image

`docker build -t bootstrap-superuser .`

### Linux console run command

`docker run --rm --name bootstrap-superuser -e TENANT_ID=diku -e ADMIN_USER=diku_admin -e ADMIN_PASSWORD=admin -e OKAPI_URL=http://okapi:9130 bootstrap-superuser`

## Alternative runnig image without compiling

`docker run --rm --name bootstrap-superuser -e TENANT_ID=diku -e ADMIN_USER=diku_admin -e ADMIN_PASSWORD=admin -e OKAPI_URL=http://okapi:9130 docker.dev.folio.org/bootstrap-superuser`

## Environment variables

When you deploy the `bootstrap-superuser` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line.

### TENANT_ID

The short name of the Tenant. Defaults to `diku`.

### ADMIN_USER

Name of the Folio superuser to create. Defaults to `diku_admin`.

### ADMIN_PASSWORD

Password to set for the Folio superuser. Defaults to `admin`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://okapi:9130`.

### FLAGS

Use to set up flags to apply permissions. Add -e FLAGS='' to create admin user and apply perrmisions. Defaults to `--onlyperms`.
