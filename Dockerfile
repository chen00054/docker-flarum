FROM alpine:3.22

LABEL description="Simple forum software for building great communities" \
      maintainer="Magicalex <magicalex@mondedie.fr>"

ARG VERSION=1.8.19

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
    GITHUB_TOKEN_AUTH=false \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    FLARUM_PORT=8888

RUN apk add --no-progress --no-cache \
    ca-certificates \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    php83 \
    php83-cli \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-fpm \
    php83-gd \
    php83-gmp \
    php83-iconv \
    php83-intl \
    php83-mbstring \
    php83-mysqli \
    php83-opcache \
    php83-pecl-apcu \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-phar \
    php83-session \
    php83-tokenizer \
    php83-xmlwriter \
    php83-zip \
    php83-zlib \
    su-exec \
    s6 \
  && cd /tmp \
  && curl --progress-bar https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && sed -i 's/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/' /etc/php83/php.ini \
  && chmod +x /usr/local/bin/composer \
  && mkdir -p /run/php /flarum/app \
  && COMPOSER_HOME="/flarum/.composer" COMPOSER_CACHE_DIR="/tmp" composer create-project --no-install flarum/flarum:$VERSION /flarum/app \
  && COMPOSER_HOME="/flarum/.composer" composer config --working-dir=/flarum/app --json audit.ignore '{"GHSA-cxf4-7mrp-vvpr":"league/flysystem 1.x is required by flarum/core 1.x and has no patched release."}' \
  && COMPOSER_HOME="/flarum/.composer" COMPOSER_CACHE_DIR="/tmp" composer install --working-dir=/flarum/app --no-interaction \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/* \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
CMD ["/usr/local/bin/startup"]
