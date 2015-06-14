#!/bin/bash

echo 'Downloading PhpMyAdmin lastest verion'

wget -q -O - http://www.phpmyadmin.net/home_page/downloads.php| grep -o 'https://.*\.tar\.xz#[^"]*' | head -1 | wget -i - -O phpmyadmin.tar.xz

mkdir phpmyadmin && tar xf phpmyadmin.tar.xz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.xz

sudo bash /vagrant/scripts/serve.sh phpmyadmin.app $(pwd)/phpmyadmin
