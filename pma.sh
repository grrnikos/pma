#!/bin/bash

echo 'Downloading phpMyAdmin 4.6.4'
curl -#L https://files.phpmyadmin.net/phpMyAdmin/4.6.4/phpMyAdmin-4.6.4-english.tar.gz -o phpmyadmin.tar.gz

mkdir phpmyadmin && tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.gz

CMD=/vagrant/scripts/serve-laravel.sh
if [ ! -f $CMD ]; then
    # fallback for older versions
    CMD=/vagrant/scripts/serve.sh
fi

sudo bash $CMD phpmyadmin.app $(pwd)/phpmyadmin
