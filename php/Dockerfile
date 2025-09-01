FROM php:8.3-fpm-alpine

RUN apk add --no-cache bash git libzip-dev oniguruma-dev icu-dev mariadb-connector-c-dev \
 && docker-php-ext-install pdo_mysql mbstring intl zip opcache

COPY php.ini /usr/local/etc/php/conf.d/php.ini
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
