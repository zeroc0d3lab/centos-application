FROM zeroc0d3lab/centos-base-workspace:latest
MAINTAINER ZeroC0D3 Team <zeroc0d3.team@gmail.com>

RUN mkdir -p /application

## SET PORT ##
EXPOSE 22

## SET VOLUME ##
VOLUME ["/application"]

## RUN INIT ##
ENTRYPOINT ["/init"]
CMD []
