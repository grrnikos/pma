#!/bin/bash

code_dir=/home/vagrant/code

if ! [ -f /home/vagrant/.phpmyadmin ]
then
    echo 'Downloading phpMyAdmin 4.7.7'
    
    curl -#L https://files.phpmyadmin.net/phpMyAdmin/4.7.7/phpMyAdmin-4.7.7-english.tar.gz -o ${code_dir}/phpmyadmin.tar.gz

    mkdir ${code_dir}/phpmyadmin && tar xf ${code_dir}/phpmyadmin.tar.gz -C ${code_dir}/phpmyadmin --strip-components 1

    rm ${code_dir}/phpmyadmin.tar.gz
    
    touch /home/vagrant/.phpmyadmin
else    
    echo "phpMyAdmin installed!"
    
    CMD=/vagrant/scripts/serve-laravel.sh
    CMD_CERT=/vagrant/scripts/create-certificate.sh

    if [ ! -f $CMD ]; then
        # Fallback for older Homestead versions
        CMD=/vagrant/scripts/serve.sh
    else
        # Create an SSL certificate
        sudo bash $CMD_CERT phpmyadmin.test
    fi

    sudo bash $CMD phpmyadmin.test $(pwd)/phpmyadmin  skipped_variables skipped_variable 7.2

    sudo service nginx reload
fi
