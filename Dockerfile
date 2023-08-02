FROM php:7.4-cli-alpine3.15

# Optional, force UTC as server time
RUN echo "UTC" > /etc/timezone

# Install essential build tools
RUN apk add --update --no-cache \
    libstdc++ g++ autoconf make curl linux-headers \
#soap
  libxml2 libxml2-dev \
#zip
  libzip libzip-dev \
#phar
  openssl openssl-dev \
#gd
  libpng libpng-dev \
#intl
  icu-dev

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
    
# Preinstalled with
# ctype curl date dom fileinfo filter ftp hash
# iconv json libxml mbstring mysqlnd openssl
# pcre PDO pdo_sqlite Phar posix readline session
# SimpleXML sodium sqlite3 standard tokenizer
# xml xmlreader xmlwriter zlib

RUN docker-php-ext-install \
    pcntl posix \
    mysqli pdo_mysql \
    zip \
    soap \
    shmop \
    phar \
    gd exif fileinfo \
    opcache 
    
RUN docker-php-ext-configure intl && docker-php-ext-install intl
    
RUN pecl install xdebug-3.1.5
RUN docker-php-ext-enable xdebug pdo_mysql
RUN echo 'xdebug.mode="coverage"' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN rm -rf /tmp/*
RUN apk del libxml2-dev libzip-dev openssl-dev libpng-dev

# Install other libs
RUN apk add --update --no-cache \
    python2 \
    openssh-client \
    git bash rsync
    
WORKDIR /opt
RUN wget https://unofficial-builds.nodejs.org/download/release/v18.9.1/node-v18.9.1-linux-x64-musl.tar.gz
RUN mkdir -p /opt/nodejs
RUN tar -zxvf *.tar.gz --directory /opt/nodejs --strip-components=1
RUN rm *.tar.gz
RUN ln -s /opt/nodejs/bin/node /usr/local/bin/node
RUN ln -s /opt/nodejs/bin/npm /usr/local/bin/npm
RUN npm install --global yarn

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/bin/bash", "-l", "-c"]
