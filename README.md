## About

Shell script that installs or updates phpMyAdmin
in a [Laravel Herd](https://herd.laravel.com) parked folder on macOS, or on a Laravel Homestead box.

It checks the download against phpMyAdmin's published checksum, leaves an existing install
alone when a download fails, and updates phpMyAdmin when you run it again
(your `config.inc.php` is kept).

## Usage

### Herd (macOS)

1. `cd` to a folder that Herd serves (a parked path, by default `~/Herd`)

2. `curl -fsS https://raw.githubusercontent.com/grrnikos/pma/master/pma.sh | bash`

3. Go to [http://phpmyadmin.test](http://phpmyadmin.test) and log in with your MySQL user, for example `root` with an empty password on [DBngin](https://dbngin.com) or Herd Pro.
   phpMyAdmin connects to `127.0.0.1` on port 3306; for another port, add `$cfg['Servers'][1]['port'] = '3307';` to `phpmyadmin/config.inc.php`

### Homestead

> Laravel Homestead is [archived](https://github.com/laravel/homestead) and no longer maintained.
> For new setups, Laravel suggests Herd.

1. SSH into your Homestead box: `vagrant ssh` from your Homestead directory

2. `cd` to your code/projects directory (by default `~/code`)

3. `curl -fsS https://raw.githubusercontent.com/grrnikos/pma/master/pma.sh | bash`

4. Open the `/etc/hosts` file on your main machine and add your box's IP, by default `192.168.56.56  phpmyadmin.test`

5. Go to [http://phpmyadmin.test](http://phpmyadmin.test). Default credentials are username `homestead` and password `secret`

### Updating

Run the `curl` step again in the same folder.

## Other setups

These don't need the script:

- **Sail**: add a service to your `compose.yaml`, then `sail up -d` and go to [http://localhost:8080](http://localhost:8080)

  ```yaml
  phpmyadmin:
      image: 'phpmyadmin:latest'
      ports:
          - '${FORWARD_PMA_PORT:-8080}:80'
      environment:
          PMA_HOST: mysql
      networks:
          - sail
      depends_on:
          - mysql
  ```

- **Docker**: `docker run --name phpmyadmin -d -e PMA_HOST=host.docker.internal -p 8080:80 phpmyadmin:latest`
  ([image docs](https://hub.docker.com/_/phpmyadmin))

- **DDEV**: `ddev add-on get ddev/ddev-phpmyadmin && ddev restart`
  ([add-on docs](https://github.com/ddev/ddev-phpmyadmin))

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
