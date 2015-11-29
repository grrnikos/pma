#!/bin/bash

echo 'Downloading PhpMyAdmin 4.4.14'
curl -#L https://files.phpmyadmin.net/phpMyAdmin/4.4.14/phpMyAdmin-4.4.14-english.tar.gz -o phpmyadmin.tar.gz

mkdir phpmyadmin && tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.gz

sudo bash /vagrant/scripts/serve-laravel.sh phpmyadmin.app $(pwd)/phpmyadmin
