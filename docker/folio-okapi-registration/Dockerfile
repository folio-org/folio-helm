FROM alpine:3.17

#Install latest patch versions of packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Prerequisites and upgrade
RUN apk upgrade \
 && apk add \
      curl jq bash \
 && rm -rf /var/cache/apk/*

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/install

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY create-deploy.sh /usr/local/bin/folio
COPY init.sh /usr/local/bin/folio
COPY platform-complete.json /usr/local/bin/folio
COPY stripes.json /usr/local/bin/folio

#Set environment variables for script
ENV OKAPI_URL='http://okapi:9130'
ENV MODULE_NAME=''
ENV MODULE_VERSION='latest'
ENV MODULE_URL=
ENV TENANT_ID='diku'
ENV SAMPLE_DATA='false'
ENV REF_DATA='false'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/init.sh"]
