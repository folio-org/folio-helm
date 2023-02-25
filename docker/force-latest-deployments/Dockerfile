FROM ubuntu:latest

#Install latest patch versions of packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Install prerequisites
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
      curl \
      postgresql-client \
 && rm -rf /var/lib/apt/lists/*

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/install

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY init.sh /usr/local/bin/folio
COPY insert_deployments.sql /usr/local/bin/folio

#Set environment variables for script
ENV DB_PASSWORD='password'
ENV DB_HOST='postgresql-db'
ENV DB_DATABASE='database-name'
ENV DB_USERNAME='postgres-user'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/init.sh"]
