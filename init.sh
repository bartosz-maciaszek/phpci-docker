#!/bin/sh

log () {
    echo "[$(date)] $1" >&2
}

fail () {
    log "$1"
    exit 1
}


retry () {
    local ATTEMPT=1
    local MAX_ATTEMPTS=5
    local DELAY=3
    while true; do
        "$@" 2>&1 && break || {
        if [[ ${ATTEMPT} -lt ${MAX_ATTEMPTS} ]]; then
            log "Command failed. Attempt $ATTEMPT/$MAX_ATTEMPTS: $@"
            ATTEMPT=`expr ${ATTEMPT} + 1`
            sleep ${DELAY};
        else
            fail "The command has failed after $ATTEMPT attempts."
        fi
    }
    done
}

if [[ ! -z "$PHPCI_DATABASE_HOST" ]] ; then
    retry nc -vz ${PHPCI_DATABASE_HOST} 3306
    log "MySQL up at ${PHPCI_DATABASE_HOST}:3306"
fi


if [ ! -f /.installed ]; then
    ./console phpci:install --queue-disabled \
        --url=$PHPCI_URL \
        --db-host=$PHPCI_DATABASE_HOST \
        --db-name=$PHPCI_DATABASE_NAME \
        --db-user=$PHPCI_DATABASE_USERNAME \
        --db-pass=$PHPCI_DATABASE_PASSWORD \
        --admin-name=$PHPCI_ADMIN_LOGIN \
        --admin-pass=$PHPCI_ADMIN_PASSWORD \
        --admin-mail=$PHPCI_ADMIN_EMAIL \
        -n
    echo $PHPCI_VERSION > /.installed
fi

nohup php daemonise phpci:daemonise &

php-fpm --allow-to-run-as-root --fpm-config /etc/php/fpm/php-fpm.conf -c /etc/php/fpm/php.ini

exec nginx