#!/bin/bash

echo 'Downloading PhpMyAdmin 4.4.11'
curl -#L https://files.phpmyadmin.net/phpMyAdmin/4.4.12/phpMyAdmin-4.4.12-english.tar.gz -o phpmyadmin.tar.gz

mkdir phpmyadmin && tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.gz

sudo bash /vagrant/scripts/serve.sh phpmyadmin.app $(pwd)/phpmyadmin
