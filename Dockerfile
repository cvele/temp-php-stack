ARG PHP_VERSION=8.1
FROM php:${PHP_VERSION}-fpm-alpine
ARG APP_DIR=/src
ARG APP_ENV=prod
ARG APP_DEBUG=0
ARG TZ=Europe/Belgrade
RUN apk add --update --no-cache tzdata
ENV TZ=${TZ}

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY .docker/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

RUN if [ "$APP_ENV" == "dev" ] || [ "$APP_ENV" == "test" ]; then \
        mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini; \
    else \
        mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini; \
    fi && \
# Install swoole
    apk update && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev && \
    docker-php-ext-install sockets && \
    docker-php-source extract && \
    mkdir /usr/src/php/ext/swoole && \
    curl -sfL https://github.com/swoole/swoole-src/archive/v4.8.8.tar.gz -o swoole.tar.gz && \
    tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole && \
    docker-php-ext-configure swoole \
        --enable-http2   \
        --enable-mysqlnd \
        --enable-openssl \
        --enable-sockets --enable-swoole-curl --enable-swoole-json && \
    docker-php-ext-install -j$(nproc) swoole && \
    rm -f swoole.tar.gz \
# Install apcu
    && pecl install apcu && docker-php-ext-enable apcu \
# Install redis
    && pecl install redis && docker-php-ext-enable redis \
# Install zip
    && apk add libzip-dev && docker-php-ext-install zip \
# Install mysql
    && docker-php-ext-install pdo pdo_mysql \
# Install intl
    && apk add icu-dev && docker-php-ext-install intl \
# Install opcache
    && docker-php-ext-install opcache \
# Install pcntl
    && docker-php-ext-install pcntl \
# Imagick 
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev libwebp-dev libwebp libwebp-tools file jpegoptim optipng libgomp libwebp-dev imagemagick imagemagick-libs imagemagick-dev \
    && docker-php-source extract \
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://api.github.com/repos/imagick/imagick/tarball | tar xvz -C /usr/src/php/ext/imagick --strip 1 \
    && docker-php-ext-install imagick \
    && docker-php-ext-enable imagick \
# /Done with php
    && apk add --update --no-cache alpine-sdk nginx supervisor bash yarn nodejs git \
# only in dev builds
    && if [ "$APP_ENV" == "dev" ]; then pecl install xdebug \
    && apk add mysql-client \
    && apk add --no-cache --update bash-completion \
    && composer global require bamarni/symfony-console-autocomplete; fi \
# Cleanup
    && mkdir -p /tmp/pear/cache && docker-php-source delete && apk del .build-deps && apk del $PHPIZE_DEPS && rm -rf /var/cache/apk/* && pecl clear-cache \
# Configure
    && echo "clear_env = no;" >> /usr/local/etc/php-fpm.d/www.conf \
    ## This is the reason for nginx and fpm on the same container
    ## we are using sockets which eliminates some overhead
    && sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/listen = 9000/;listen = 9000/" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && rm -rf /usr/local/etc/php-fpm.d/www.conf.default \
    && echo "ping.path = /ping;" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "ping.response = pong;" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.status_path = /status;" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_requests = 500;" >> /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/root/www-data/" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/;clear_env = .*/clear_env = no/" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/user = .*/user = root/" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = .*/group = root/" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/error_log = .*/error_log = \/dev\/stderr/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/access.log = .*/access.log = \/dev\/stdout/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/catch_workers_output = .*/catch_workers_output = yes/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/;log_level = .*/log_level = notice/" /usr/local/etc/php-fpm.conf \
    && sed -i "s/variables_order = .*/variables_order = \"EGPCS\"/" /usr/local/etc/php/php.ini \
    && mkdir -p /var/log/php \
    && touch /var/log/xdebug.log \
    && mkdir ${APP_DIR} \
    && mkdir -p ${APP_DIR}/vendor \
    && chown -R nobody.nobody ${APP_DIR} \
    && echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
    && echo "pm.max_children = 8" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "ping.path = /ping.php" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "ping.response = pong" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_requests = 500" >> /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/error_log = .*/error_log = \/dev\/stderr/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/access.log = .*/access.log = \/dev\/stdout/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/catch_workers_output = .*/catch_workers_output = yes/" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/;log_level = .*/log_level = warning/" /usr/local/etc/php-fpm.conf

WORKDIR ${APP_DIR}

COPY . ${APP_DIR}

RUN if [ "$APP_ENV" == "dev" ]; then cp .docker/bashrc /root/.bashrc; fi \
    && if [ "$APP_ENV" == "prod" ]; then rm -rf vendor \ 
    && rm -rf public/build/* public/bundles/* public/info.php \
    && composer install --no-scripts --no-interaction \
    && composer dump-env prod \ 
    && rm -rf var/* && mkdir -p var/cache/prod && mkdir -p var/log \
    && composer install --no-dev --classmap-authoritative --no-interaction --optimize-autoloader \
    && yarn install --force \ 
    && yarn run encore production \ 
    && rm -rf node_modules \ 
    && bin/console cache:clear \ 
    && apk del nodejs yarn git \
    && rm -rf assets node_modules var/* tests .vscode .docker .github .packer .terraform \
    && bin/console cache:warmup; fi \
    && chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /src/bin/console /usr/local/bin/app

CMD ["/usr/local/bin/docker-entrypoint.sh"]
