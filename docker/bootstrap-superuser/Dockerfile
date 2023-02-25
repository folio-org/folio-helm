FROM alpine:3.17

#Install latest patch versions of packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Install prerequisites
RUN apk upgrade \
 && apk add \
      make curl perl perl-app-cpanminus perl-json perl-libwww perl-lwp-protocol-https \
 && rm -rf /var/cache/apk/*
RUN cpanm UUID::Tiny

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY bootstrap-superuser.pl /usr/local/bin/folio
COPY create-superuser.sh /usr/local/bin/folio

#Set environment variables for script
ENV TENANT_ID='diku'
ENV ADMIN_USER='diku_admin'
ENV ADMIN_PASSWORD='admin'
ENV OKAPI_URL='http://okapi:9130'
ENV FLAGS='--onlyperms'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-superuser.sh"]
