FROM           debian:wheezy
MAINTAINER     David GUENAULT

ENV     distro wheezy
ENV     ocversion 8.0.4

# upgrade system
RUN     apt-get update && apt-get -y upgrade

# prerequisites
RUN     apt-get -y install apache2 php5 php5-gd php5-json php5-mysql php5-curl php5-intl php5-mcrypt \
        php5-ldap php5-gmp php-apc php5-imagick

# installation
RUN     apt-get -y install wget bzip2 && \
        cd /tmp && \
        wget https://download.owncloud.org/community/owncloud-${ocversion}.tar.bz2 && \
        wget https://download.owncloud.org/community/owncloud-${ocversion}.tar.bz2.asc && \
        wget https://www.owncloud.org/owncloud.asc && \
        gpg --import owncloud.asc && \
        gpg --verify owncloud-${ocversion}.tar.bz2.asc owncloud-${ocversion}.tar.bz2 && \
        tar jxvf owncloud-${ocversion}.tar.bz2 && \
        cp -a owncloud /var/www/ && \
        chown -R www-data:www-data /var/www/owncloud

# apache configuration
COPY    apache/owncloud.conf /etc/apache2/conf.d/owncloud.conf

RUN     a2enmod rewrite && \
        a2enmod ssl && \
        a2ensite default-ssl

# cleanup
RUN     rm -Rf /tmp/*

# daemon manager
RUN     apt-get -y install supervisor 
COPY    supervisor/apache.conf /etc/supervisor/conf.d/apache.conf
CMD     ["/usr/bin/supervisord", "-n",  "-c", "/etc/supervisor/supervisord.conf"]
