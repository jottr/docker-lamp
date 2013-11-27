# runnable base
FROM boxcar/raring

MAINTAINER github.com/jottr
# based on https://github.com/Runnable/dockerfiles

# REPOS
RUN apt-get -y update && date
RUN apt-get install -y -q software-properties-common
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get -y update

#SHIMS

## Hack for initctl
## See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# ENVIRONMENT
ENV TZ Europe/Berlin

# EDITORS
RUN apt-get install -y -q vim-tiny

# TOOLS
RUN apt-get install -y -q curl git make wget

# LANGS

## PHP
RUN apt-get install -y -q php5 php5-cli php5-dev php-pear php5-fpm php5-common php5-mcrypt php5-gd php-apc php5-curl php5-tidy


# SERVICES

## SUPERVISOR
RUN apt-get install -y -q supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## SSH 
RUN apt-get install -y -q openssh-server
RUN mkdir -p /var/run/sshd
 
 

## MEMCACHED
#RUN apt-get install -y -q memcached
#RUN pecl install memcache

## MAGICK
#RUN apt-get install -y -q imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php5-imagick
#RUN pecl install imagick

## APACHE
RUN apt-get install -y -q apache2 libapache2-mod-php5
RUN a2enmod rewrite

ADD apache_foreground.sh /etc/apache2/apache_foreground.sh
RUN chmod 755 /etc/apache2/apache_foreground.sh

## MYSQL
RUN apt-get install -y -q mysql-client mysql-server php5-mysql
RUN mysqld & sleep 2 && mysqladmin create mydb


## APP
RUN rm -rf /var/www/*
ADD app /var/www

## CREDENTIALS
RUN echo "root:root" | chpasswd

## PORTS
EXPOSE 80
EXPOSE 22

CMD ["/usr/bin/supervisord", "-n"]


# RESET

#ENV DEBIAN_FRONTEND dialog

## CONFIG
#ENV RUNNABLE_USER_DIR /var/www
#ENV RUNNABLE_SERVICE_CMDS memcached -d -u www-data; /etc/init.d/apache2 restart; mysqld
