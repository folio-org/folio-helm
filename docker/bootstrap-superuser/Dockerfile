FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache make curl perl perl-app-cpanminus perl-json perl-libwww perl-lwp-protocol-https
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
ENV ONLY_PERMS='--onlyperms'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-superuser.sh"]
