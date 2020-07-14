FROM ubuntu:latest

#Prerequisites
RUN apt-get update
RUN apt-get install curl postgresql-client -y

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
