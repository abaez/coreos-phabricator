FROM ubuntu:trusty

MAINTAINER Alejandro Baez

# Installing required packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ssh openssh-server apache2 curl mercurial git supervisor vim.tiny ca-certificates nodejs

# Installing required php packages
RUN apt-get -y install --no-install-recommends php5-curl php5-cli php5-mysql php-pear php5-mysql php5-gd php5-dev php5-curl php-apc php5-cli php5-json libapache2-mod-php5

# User access on apache
RUN apt-get -y install --no-install-recommends apache2-mpm-itk 

# Clean packages 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# ports for ssh (2244 for regular SSH, 22 for hg)
EXPOSE 2244 22

# Expose Apache on port 80 
EXPOSE 80 

# Expose Aphlict (notification server) on 843 and 22280
EXPOSE 843 22280

# Adding user
RUN echo "hg:x:2000:2000:user for phabricator:/srv:/bin/bash" >> /etc/passwd
RUN echo "phabricator:x:2001:2000:user for phabricator daemons:/srv:/bin/bash" >> /etc/passwd
RUN echo "www-phabricator:!:2000:www-data" >> /etc/group

RUN echo "hg ALL=(phabricator) SETENV: NOPASSWD: /usr/bin/hg" >>  /etc/sudoers.d/hg

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
RUN mkdir /etc/phabricator-ssh
RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
ADD add/sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator
ADD add/phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh
RUN chown root:root /etc/phabricator-ssh -R

# The configuring apache for phabricator
RUN rm /var/www/html -rf
RUN rm /etc/apache2/sites-enabled/000-default.conf 
ADD add/phabricator.conf /etc/apache2/sites-enabled/phabricator.conf


# setting up supervisord
ADD add/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor
RUN a2enmod rewrite
#RUN service supervisor restart
#RUN supervisorctl reread; supervisorctl update

# making default directories
RUN mkdir -p /var/lib/mysql
RUN mkdir -p /var/repo
RUN chown phabricator:2000 /var/repo
RUN mkdir -p /var/tmp/phd/pid
RUN chmod 0777 /var/tmp/phd/pid
RUN mkdir /config

VOLUME /srv/phabricator/conf/local

# Setting up startup
ADD add/startup.sh /srv/startup.sh
RUN chmod +rwx /srv/startup.sh

WORKDIR /srv/phabricator
CMD ["/srv/startup.sh"]
