FROM zeroc0d3lab/centos-base-workspace:latest
MAINTAINER ZeroC0D3 Team <zeroc0d3.team@gmail.com>

## CREATE WORKSPACE APPLICATION FOLDER ##
RUN mkdir -p /application

## SETUP LOCALE ##
RUN ["/usr/bin/localedef", "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8"]

## SET PORT ##
EXPOSE 22

## SET VOLUME ##
VOLUME ["/application"]

## RUN INIT ##
ENTRYPOINT ["/init"]
CMD []
