FROM tutum/apache-php

MAINTAINER Alejandro Baez

RUN apt-get update; apt-get install -yq ssh openssh-server curl vim less mercurial git

RUN apt-get -yq install php5-curl php5-cli php5-mysql php5-dev php5-gd php5-pear php5-apc php5-json php5-mbstring

# ports for ssh (2244 for regular SSH, 22 for hg)
EXPOSE 2244 22

# Expose Apache on port 80 
EXPOSE 80 

# Expose Aphlict (notification server) on 843 and 22280
EXPOSE 843 22280

# Adding user
RUN echo "hg:x:2000:2000:user for phabricator:/srv:/bin/bash" >> /etc/passwd
RUN echo "www-phabricator:!:2000:www-data" >> /etc/group

#RUN echo "hg ALL=(www-data) SETENV: NOPASSWD: /usr/bin/hg" >>  /etc/sudoers.d/hg

# set up phabricator
RUN chown hg:www-phabricator /srv
USER hg
WORKDIR /srv 
RUN git clone https://github.com/phacility/libphutil.git
RUN git clone https://github.com/phacility/arcanist.git
RUN git clone https://github.com/phacility/phabricator.git
USER root
WORKDIR /

# Move the default SSH to port 2244
RUN echo "Port 2244" >> /etc/ssh/sshd_config

# Configure SSH for phabricator
ADD ./add/sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator
ADD ./add/phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh
RUN chown root:root /etc/phabricator-ssh -R
