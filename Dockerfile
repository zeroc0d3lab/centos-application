FROM zeroc0d3lab/centos-base-workspace:latest
MAINTAINER ZeroC0D3 Team <zeroc0d3.team@gmail.com>

## SET PORT ##
EXPOSE 22

## SET VOLUME ##
VOLUME ["/sys/fs/cgroup", "/tmp"]

## RUN INIT ##
CMD ["/usr/sbin/init"]
