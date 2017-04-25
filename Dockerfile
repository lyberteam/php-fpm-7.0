FROM php:7.0-fpm

ADD lyberteam-message.sh /var/www/lyberteam/lyberteam-message.sh
RUN chmod +x /var/www/lyberteam/lyberteam-message.sh
RUN /var/www/lyberteam/lyberteam-message.sh && rm -f /var/www/lyberteam/lyberteam-message.sh


MAINTAINER Lyberteam <lyberteamltd@gmail.com>
LABEL Vendor="Lyberteam"
LABEL Description="PHP-FPM v7.0-fpm"
LABEL Version="1.0.1"

RUN apt-get update && apt-get install -y \
        libicu-dev \
        libpq-dev \
        libbz2-dev \
        php-pear \
        git \
        unzip \
        mc \
        vim \
        wget \
        libevent-dev \
        librabbitmq-dev \
    && docker-php-ext-install iconv \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install intl \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache

# Install GD
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libmcrypt-dev \
     && docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-freetype-dir=/usr/include/freetype2 \
          --with-png-dir=/usr/include \
          --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd

## Install Xdebug
RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.5.3.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
        cd xdebug \
        && phpize \
        && ./configure --enable-xdebug \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini

# Change TimeZone
RUN echo "Set default timezone - Europe/Kiev"
RUN echo "Europe/Kiev" > /etc/timezone

# Install composer globally
RUN echo "Install composer globally"
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

COPY php.ini /usr/local/etc/php/php.ini

RUN /bin/bash -c 'rm -f /usr/local/etc/php-fpm.d/www.conf.default'
ADD symfony.pool.conf /usr/local/etc/php-fpm.d/
RUN rm -f /usr/local/etc/php-fpm.d/www.conf


RUN usermod -u 1000 www-data

CMD ["php-fpm"]

## Let's set the working dir
VOLUME /var/www/lyberteam


EXPOSE 9000

RUN  dpkg-reconfigure -f noninteractive tzdata
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#
######################################## Other extensions ########################################
## Install opcache
#RUN docker-php-ext-install opcache
#
## Install APCu
#RUN pecl install apcu
#RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini
#
## Install bcmath
#RUN docker-php-ext-install bcmath
#
## Install bz2
#RUN apt-get install -y libbz2-dev
#RUN docker-php-ext-install bz2
#
## Install calendar
#RUN docker-php-ext-install calendar
#
## Install dba
#RUN docker-php-ext-install dba
#
## Install GD
#RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
#RUN docker-php-ext-install gd
#
## Install mbstring
#RUN docker-php-ext-install mbstring
#
## Install mcrypt
#RUN apt-get install -y libmcrypt-dev
#RUN docker-php-ext-install mcrypt
#
## Install PDO
## RUN apt-get install -y freetds-dev php5-sybase
## RUN docker-php-ext-install pdo
#RUN docker-php-ext-install pdo_mysql
## RUN docker-php-ext-install pdo_oci
## RUN docker-php-ext-install pdo_odbc
#RUN apt-get install -y libpq-dev
#RUN docker-php-ext-install pdo_pgsql
## RUN apt-get install -y libsqlite3-dev
## RUN docker-php-ext-install pdo_sqlite
#
## Install phpredis 2.2.7
#RUN apt-get install -y unzip
#WORKDIR /root
#COPY phpredis-2.2.7.zip phpredis-2.2.7.zip
#RUN unzip phpredis-2.2.7.zip
#WORKDIR phpredis-2.2.7
#RUN phpize
#RUN ./configure
#RUN make && make install
##RUN cp /root/phpredis-2.2.7/modules/redis.so /usr/local/lib/php/extensions/no-debug-non-zts-20151012/
#RUN echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
#
## Install XSL
#RUN apt-get install -y libxslt-dev
#RUN docker-php-ext-install xsl
#
## Install xmlrpc
#RUN docker-php-ext-install xmlrpc
#
#
## Install memcached
#COPY memcached-2.2.0.zip memcached-2.2.0.zip
#RUN apt-get install -y libmemcached-dev zlib1g-dev libncurses5-dev
#RUN mkdir /usr/src/php/ext/memcached-2.2.0
#RUN unzip memcached-2.2.0.zip -d /usr/src/php/ext/memcached-2.2.0
#RUN rm memcached-2.2.0.zip
#RUN docker-php-ext-install memcached-2.2.0
#
## Install mongo
##RUN pecl install mongodb-beta
##RUN echo "extension=mongo.so" > /usr/local/etc/php/conf.d/mongo.ini
#
## Install ftp
#RUN docker-php-ext-install ftp
#
## Install intl
#RUN apt-get install -y libicu-dev
#RUN pecl install intl
#RUN docker-php-ext-install intl
######################################## Other extensions ########################################


