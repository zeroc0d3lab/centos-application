FROM zeroc0d3lab/centos-base-consul:latest
MAINTAINER ZeroC0D3 Team <zeroc0d3.team@gmail.com>

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV SSH_AUTHORIZED_KEYS='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJSmTg48jLvAnLk5e4X27Hc37bwerd/dtmZ+xeBmtLJQBjkPGajB8/fecx2R2i29ZkN4RiMOFXCw5B/DkJuxVjHenIkg15SPeGOaM6VJ+fIgzr+zs//0QSsGdjCIilcpMYL7qx3ZujQ3kS/T7oSR28w9unWO54X3N3H8T+RvCV6Jbi7NjVt97VI52KvqM/XOGClqmTz+bAQC485rpn3wHcYvRW+aWqvwYIE1xNT8PDQUEVWzlu+kcaIYjFpdl6ThUbevxuPvLaRZpXC3IxSyeInpkjvoxKtA4SGlFDwQ82zu8yrgDXEVdD0o8B4b9LWjKWeOkepdgzwpqPh1dpWkZxRloHTP6idBScphCZ/OzI1uvc9gpIK1T6h2JB0MAFuyFr16N6JitmaVlxhLNxSpbtFjMp+XIvpdkxzMyteb00v+XTJydmrw/veEW4/An1uUrzo8wEhO2TuS2BfqGXQg18cS6mQ9veZW8TFLXFr2W35/TD2Qk0nnRW6LCJ1Fo/sfviWPQ8BWVx3zFWzYURYE8kXFkLcYgWK0oXkWMNC5j2d8w/Joh5WgJkvnhyTnRdoiOoyYcULeCvnzblfxxch1nUfDPPmw6hHwC+s9wfRCc9UYql4AHNEOoiEZjzsM7zfyb5twYMj9ijfVrbfS1vipIvr9p8pfWPgbCboF4Xl2PU0w== zeroc0d3.team@gmail.com' \
	SSH_AUTOSTART_SSHD=true \
	SSH_AUTOSTART_SSHD_BOOTSTRAP=true \
	SSH_CHROOT_DIRECTORY='%h' \
	SSH_INHERIT_ENVIRONMENT=false \
	SSH_SUDO='ALL=(ALL) ALL' \
	SSH_USER='docker' \
	SSH_USER_FORCE_SFTP=false \
	SSH_USER_HOME='/home/%u'\
	SSH_USER_ID='500:500' \
	SSH_USER_PASSWORD='docker' \
	SSH_ROOT_PASSWORD='docker' \
	SSH_USER_PASSWORD_HASHED=false \
	SSH_USER_SHELL='/bin/bash'

#-----------------------------------------------------------------------------
# Find Fastest Repo & Update Repo
#-----------------------------------------------------------------------------
RUN yum makecache fast \
	  && yum -y update

#-----------------------------------------------------------------------------
# Install Workspace Dependency
#-----------------------------------------------------------------------------
RUN yum -y install \
	           --setopt=tsflags=nodocs \
	           --disableplugin=fastestmirror \
         libnice-devel \
    && ln -sf /usr/bin/nice /bin/nice \

#-----------------------------------------------------------------------------
# Clean Up All Cache
#-----------------------------------------------------------------------------
    && yum clean all

#-----------------------------------------------------------------------------
# Setup Locale UTF-8
#-----------------------------------------------------------------------------
RUN ["/usr/bin/localedef", "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8"]

# -----------------------------------------------------------------------------
# Install supervisord (required to run more than a single process in a container)
# Note: EPEL package lacks /usr/bin/pidproxy
# We require supervisor-stdout to allow output of services started by
# supervisord to be easily inspected with "docker logs".
# -----------------------------------------------------------------------------
RUN easy_install \
		'supervisor == 3.3.1' \
		'supervisor-stdout == 0.1.1' \
	&& mkdir -p \
		/var/log/supervisor/

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf \
		/usr/share/zoneinfo/UTC \
		/etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Configure SSH for non-root public key authentication
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^PasswordAuthentication yes~PasswordAuthentication no~g' \
	-e 's~^#PermitRootLogin yes~PermitRootLogin no~g' \
	-e 's~^#UseDNS yes~UseDNS no~g' \
	-e 's~^\(.*\)/usr/libexec/openssh/sftp-server$~\1internal-sftp~g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Enable the wheel sudoers group
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^# %wheel\tALL=(ALL)\tALL~%wheel\tALL=(ALL) ALL~g' \
	-e 's~\(.*\) requiretty$~#\1requiretty~' \
	/etc/sudoers

#-----------------------------------------------------------------------------
# Finalize (reconfigure)
#-----------------------------------------------------------------------------
COPY rootfs/ /

RUN mkdir -p \
		/etc/supervisord.d/ \
	&& cp -pf \
		/etc/ssh/sshd_config \
		/etc/services-config/ssh/ \
	&& ln -sf \
		/etc/services-config/ssh/sshd_config \
		/etc/ssh/sshd_config \
	&& ln -sf \
		/etc/services-config/ssh/sshd-bootstrap.conf \
		/etc/sshd-bootstrap.conf \
	&& ln -sf \
		/etc/services-config/ssh/sshd-bootstrap.env \
		/etc/sshd-bootstrap.env \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.conf \
		/etc/supervisord.conf \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.d/sshd-wrapper.conf \
		/etc/supervisord.d/sshd-wrapper.conf \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.d/sshd-bootstrap.conf \
		/etc/supervisord.d/sshd-bootstrap.conf \
	&& chmod 700 \
		/usr/sbin/{scmi,sshd-{bootstrap,wrapper}}

USER root
#-----------------------------------------------------------------------------
# Change root Password
#-----------------------------------------------------------------------------
RUN echo 'root:'${SSH_ROOT_PASSWORD} | chpasswd

#-----------------------------------------------------------------------------
# Generate Public Key
#-----------------------------------------------------------------------------
# Create new public key
# RUN /usr/bin/ssh-keygen -t rsa -b 4096 -C "zeroc0d3.team@gmail.com" -f $HOME/.ssh/id_rsa

RUN touch $HOME/.ssh/authorized_keys \
    && chmod 700 $HOME/.ssh \
    && chmod go-w $HOME $HOME/.ssh \
    && chmod 600 $HOME/.ssh/authorized_keys \
    && chown `whoami` $HOME/.ssh/authorized_keys \
	  && echo ${SSH_AUTHORIZED_KEYS} > $HOME/.ssh/authorized_keys

ONBUILD RUN mkdir -p /home/docker/.ssh \
            && touch /home/docker/.ssh/authorized_keys \
            && echo ${SSH_AUTHORIZED_KEYS} > /home/docker/.ssh/authorized_keys

#-----------------------------------------------------------------------------
# Create Workspace Application Folder
#-----------------------------------------------------------------------------
RUN ["mkdir", "-p", "/application"]

#-----------------------------------------------------------------------------
# Set PORT Docker Container
#-----------------------------------------------------------------------------
EXPOSE 22

#-----------------------------------------------------------------------------
# Set Volume Application
#-----------------------------------------------------------------------------
VOLUME ["/application", "/root"]

#-----------------------------------------------------------------------------
# Run Init Docker Container
#-----------------------------------------------------------------------------
ENTRYPOINT ["/init"]
CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]

## NOTE:
## *) Run vim then >> :PluginInstall
## *) Update plugin vim (vundle) >> :PluginUpdate
