FROM node:22-bookworm-slim AS frontend
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci
COPY babel.config.json gulpfile.js ./
COPY assets/ ./assets/
RUN ./node_modules/.bin/gulp compile

FROM php:8.3-apache-bookworm AS php-base
RUN apt-get update \
    && apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev apache2-utils unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j "$(nproc)" gd mysqli zip \
    && a2dismod mpm_event mpm_worker \
    && a2enmod mpm_prefork \
    && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && rm -rf /var/lib/apt/lists/*

FROM php-base AS dependencies
WORKDIR /build
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY composer.json composer.lock ./
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --no-interaction --no-progress --prefer-dist \
    && composer check-platform-reqs --no-dev

FROM php-base
WORKDIR /var/www/html
COPY index.php ./
COPY application/ ./application/
COPY system/ ./system/
COPY --from=frontend /build/assets/ ./assets/
COPY --from=dependencies /build/vendor/ ./vendor/
COPY deploy/railway/config.php ./config.php
COPY deploy/railway/health.php ./healthz.php
COPY deploy/railway/site.conf /etc/apache2/sites-available/000-default.conf
COPY --chmod=755 deploy/railway/start.sh /usr/local/bin/easyappointments-start
RUN printf 'Listen ${PORT}\n' > /etc/apache2/ports.conf

CMD ["easyappointments-start"]
