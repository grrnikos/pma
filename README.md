## About

Simple shell script that automatically installs the latest version of PhpMyAdmin
on a Laravel Homestead box.

## Usage

1. SSH into your Homestead box and `cd` to your code/projects directory

2. `$ curl -sS https://raw.githubusercontent.com/grrnikos/pma/master/pma.sh | sh`

3. Open the `/etc/hosts` file on your main machine and add
```127.0.0.1  phpmyadmin.app```

4. Go to [http://phpmyadmin.app:8000](http://phpmyadmin.app:8000)

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
