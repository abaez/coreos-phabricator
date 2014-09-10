FROM tutum/apache-php

MAINTAINER Alejandro Baez

# Installing required packages
RUN apt-get update && apt-get install -y ssh openssh-server curl vim less mercurial git supervisor apache2-mpm-itk

# Installing required php packages
RUN apt-get -y install php5-curl php5-cli php5-mysql php-pear php5-mysql php5-gd php5-dev php5-curl php-apc php5-cli php5-json


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
ADD add/sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator
ADD add/phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh
RUN chown root:root /etc/phabricator-ssh -R
RUN mkdir -p /var/run/sshd

# The configuring apache for phabricator
RUN rm /var/www/html /app -rf
RUN rm /etc/apache2/sites-enabled/000-default.conf 
ADD add/phabricator.conf /etc/apache2/sites-enabled/phabricator.conf


# setting up supervisord
ADD add/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD add/bootup.sh /etc/init.d/bootup.sh
RUN chmod +rwx /etc/init.d/bootup.sh
RUN mkdir -p /var/log/supervisor
RUN a2enmod rewrite
#RUN service supervisor restart
#RUN supervisorctl reread; supervisorctl update

# making default directories
RUN mkdir -p /var/lib/mysql
RUN mkdir -p /var/repo
RUN mkdir /config

# Clean packages 
RUN apt-get clean

VOLUME /srv/phabricator/conf/local

WORKDIR /srv/phabricator
CMD ["/usr/bin/supervisord"]
