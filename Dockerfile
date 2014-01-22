# base
FROM jottr/docker-base

MAINTAINER github.com/jottr
# based on https://github.com/Runnable/dockerfiles


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
