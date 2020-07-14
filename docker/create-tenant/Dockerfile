FROM alpine:3.11

#Prerequisites
RUN apk add --no-cache curl jq bash && rm -rf /var/cache/apk/*

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/install

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY create-deploy.sh /usr/local/bin/folio

#Set environment variables for script
ENV OKAPI_URL='http://okapi:9130'
ENV TENANT_ID='diku'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-deploy.sh"]
