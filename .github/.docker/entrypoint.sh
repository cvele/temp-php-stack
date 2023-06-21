#!/bin/bash -e

rm -rf "$PHP_INI_DIR/conf.d/memory-limit.ini" \
    "$PHP_INI_DIR/conf.d/upload-limit.ini" \
    "$PHP_INI_DIR/conf.d/max-execution-time.ini" \
    "$PHP_INI_DIR/conf.d/realpath.ini" \
    "$PHP_INI_DIR/conf.d/opcache.ini"

echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
    && echo "max_execution_time=${MAX_EXECUTION_TIME:-600}" >> "$PHP_INI_DIR/conf.d/max-execution-time.ini" \
    && echo "upload_max_filesize=${UPLOAD_MAX_FILE_SIZE:-100M}" >> "$PHP_INI_DIR/conf.d/upload-limit.ini" \
    && echo "post_max_size=${POST_MAX_SIZE:-100M}" >> "$PHP_INI_DIR/conf.d/upload-limit.ini" \
    && echo "realpath_cache_size = ${REALPATH_CACHE_SIZE:-4096K}" >> "$PHP_INI_DIR/conf.d/realpath.ini" \
    && echo "realpath_cache_ttl = ${REALPATH_CACHE_TTL:-600}" >> "$PHP_INI_DIR/conf.d/realpath.ini" \
    && echo "[opcache]" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.revalidate_freq=${OPCACHE_REVALIDATE_FREQ:-0}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.validate_timestamps=${OPCACHE_VALIDATE_TIMESTAMPS:-0}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.max_accelerated_files=${OPCACHE_MAX_ACCELERATED_FILES:-60000}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.memory_consumption=${OPCACHE_MEMORY_CONSUMPTION:-256}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.max_wasted_percentage=${OPCACHE_MAX_WASTED_PERCENTAGE:-10}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.interned_strings_buffer=${OPCACHE_INTERNED_STRINGS_BUFFER:-64}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.fast_shutdown=${OPCACHE_FAST_SHUTDOWN:-1}" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.preload=/src/var/cache/prod/App_KernelProdContainer.preload.php" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.preload_user=root" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "pm.max_children = ${PHP_FPM_MAX_CHILDREN:-8}" >> /usr/local/etc/php-fpm.d/www.conf
if [ "$APP_ENV" == "dev" ] || [ "$APP_ENV" == "test" ]; then
    export APP_ENV=dev
    export APP_DEBUG=1
    export HTTPS=off
    echo "[INFO] DEV mode is on."
    echo "opcache.enable=${OPCACHE_ENABLED:-0}" >> "$PHP_INI_DIR/conf.d/opcache.ini"
    echo "opcache.enable_cli=${OPCACHE_ENABLED:-0}" >> "$PHP_INI_DIR/conf.d/opcache.ini"

    echo "xdebug.mode=${XDEBUG_MODE:-debug}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "xdebug.remote_handler = ${XDEBUG_REMOTE_HANDLER:-dbgp}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "xdebug.client_host = ${XDEBUG_HOST:-host.docker.internal}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "xdebug.client_port = ${XDEBUG_PORT:-9000}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "xdebug.start_with_request = ${XDEBUG_START_WITH_REQUEST:-yes}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "xdebug.idekey = ${XDEBUG_IDEKEY:-VSCODE}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    touch ${XDEBUG_LOG:-/var/log/xdebug.log}
    chmod 777 ${XDEBUG_LOG:-/var/log/xdebug.log}
    echo "xdebug.log=${XDEBUG_LOG:-/var/log/xdebug.log}" >> "$PHP_INI_DIR/conf.d/xdebug.ini"
    docker-php-ext-enable xdebug
    
    if [ "$QUICK_BOOT" != "true" ]; then
        composer install --optimize-autoloader
        yarn install --force
        yarn run encore dev
    fi
    
    wait-for-it.sh $DATABASE_HOST:3306 --timeout=120
    wait-for-it.sh elasticsearch:9200 --timeout=120
    bin/console doctrine:migrations:migrate --no-interaction
    
    user_count=$(mysql -P $DATABASE_PORT -h $DATABASE_HOST $DATABASE_NAME -u$DATABASE_USERNAME -p$DATABASE_PASSWORD -s -N -e "select count(*) from users;")
    if [[ "$user_count" < 1 ]]; then
        echo "[INFO] No users found in database."
        echo "[INFO] This is dev environment - running fixtures."
        composer fixtures-initial-load
        composer fixtures-content-load
        bin/console fos:elastica:populate
    fi
    
    yarn run encore dev --watch&
else
    echo "[INFO] PROD mode is on."
    export APP_ENV=prod
    export APP_DEBUG=0
    export HTTPS=on
    echo "[INFO] Setting up opcache."
    echo "opcache.enable=${OPCACHE_ENABLED:-1}" >> "$PHP_INI_DIR/conf.d/opcache.ini"
    echo "opcache.enable_cli=${OPCACHE_ENABLED:-0}" >> "$PHP_INI_DIR/conf.d/opcache.ini"
    echo "[INFO] Removing xdebug."
    rm -rf "$PHP_INI_DIR/conf.d/xdebug.ini"
    echo "[INFO] Executing migrations"
    wait-for-it.sh $DATABASE_HOST:3306 --timeout=60
    # bin/console doctrine:migrations:migrate --no-interaction
    echo "[INFO] Starting application."
fi

/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
