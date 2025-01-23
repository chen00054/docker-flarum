FROM php:8.2-fpm-alpine

LABEL description="Simple forum software for building great communities" \
      maintainer="Magicalex <magicalex@mondedie.fr>"

ARG VERSION=1.8.9

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE=Docker-Flarum \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    FLARUM_PORT=8888

RUN apk update && apk add --no-progress --no-cache \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    su-exec \
    s6 \
    build-base \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    gmp-dev \
    libxml2-dev \
    autoconf \
    bash \
    && docker-php-ext-install \
        ctype \
        curl \
        exif \
        fileinfo \
        gd \
        gmp \
        iconv \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        session \
        tokenizer \
        xmlwriter \
        zip \
  && cd /tmp \
  && curl --progress-bar http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/php.ini \
  && chmod +x /usr/local/bin/composer \
  && mkdir -p /run/php /flarum/app \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum:$VERSION /flarum/app \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/* \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
CMD ["/usr/local/bin/startup"]
