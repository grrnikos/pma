#!/bin/bash

# From https://stackoverflow.com/a/59825964/5155484
VERSION_INFO="$(curl -sS 'https://www.phpmyadmin.net/home_page/version.txt')"
LATEST_VERSION="$(echo -e "$VERSION_INFO" | head -n 1)"
LATEST_VERSION_URL="$(echo -e "$VERSION_INFO" | tail -n 1)"
# We want the .tar.gz version
LATEST_VERSION_URL="${LATEST_VERSION_URL/.zip/.tar.gz}"

echo "Downloading phpMyAdmin $LATEST_VERSION ($LATEST_VERSION_URL)"
curl $LATEST_VERSION_URL -q -# -o 'phpmyadmin.tar.gz'

mkdir phpmyadmin && tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.gz

VAGRANT_SCRIPTS=${VAGRANT_SCRIPTS:-/vagrant/scripts/}

CMD=${VAGRANT_SCRIPTS}site-types/laravel.sh
CMD_CERT=${VAGRANT_SCRIPTS}create-certificate.sh

if [ ! -f $CMD ]; then
    # Fallback for older Homestead versions
    CMD=${VAGRANT_SCRIPTS}serve.sh
else
    # Create an SSL certificate
    sudo bash $CMD_CERT phpmyadmin.test
fi

sudo bash $CMD phpmyadmin.test $(pwd)/phpmyadmin 80 443

sudo service nginx reload
