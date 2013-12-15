# base
FROM stackbrew/ubuntu:raring

MAINTAINER github.com/jottr
# based on https://github.com/Runnable/dockerfiles

## Speed and Space
# see https://gist.github.com/jpetazzo/6127116
# this forces dpkg not to call sync() after package extraction and speeds up install
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
# we don't need and apt cache in a container
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# REPOS
RUN apt-get -y update && date
RUN apt-get install -y -q software-properties-common
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get -y update

# SHIMS

## Hack for initctl
## See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# ENVIRONMENT
ENV TZ Europe/Berlin
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

### PACKAGES ###

# EDITORS
RUN apt-get install -y -q vim-tiny

# TOOLS
RUN apt-get install -y -q curl git make wget

## PHP
RUN apt-get install -y -q php5 php5-cli php5-dev php-pear php5-fpm php5-common php5-mcrypt php5-gd php-apc php5-curl php5-tidy php5-xmlrpc

## SUPERVISOR
RUN apt-get install -y -q supervisor

## SSH 
RUN apt-get install -y -q openssh-server
RUN mkdir -p /var/run/sshd
 
## MEMCACHED
#RUN apt-get install -y -q memcached
#RUN pecl install memcache

## MAGICK
RUN apt-get install -y -q imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php5-imagick
RUN pecl install imagick

## MYSQL
#RUN apt-get install -y -q mysql-client mysql-server php5-mysql
RUN apt-get install -y -q mysql-client php5-mysql

## COMPOSER
#RUN curl -sS https://getcomposer.org/installer | php
#RUN mv composer.phar /usr/local/bin/composer
#RUN composer create-project silverstripe/installer /var/www/ 

## APACHE
RUN apt-get install -y -q apache2 libapache2-mod-php5

# CONFIGURATION & FILES

### Enable url rewrites
RUN a2enmod rewrite
RUN sed -i -e '\_<Directory \/var_,\_<\/Directory_  s_None_All_'  /etc/apache2/sites-available/default

ADD apache_foreground.sh /etc/apache2/apache_foreground.sh
RUN chmod 755 /etc/apache2/apache_foreground.sh

ADD php.ini /etc/php5/apache2/php.ini
RUN chmod 755 /etc/php5/apache2/php.ini



## MYSQL
#RUN mysqld & sleep 2 && mysqladmin create mydb

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf


## CREDENTIALS
RUN echo "root:root" | chpasswd

## PORTS
EXPOSE 80
EXPOSE 22


CMD /bin/chown -R www-data:www-data /var/www && /usr/bin/supervisord -n 
