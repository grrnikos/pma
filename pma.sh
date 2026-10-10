#!/bin/bash
# Installs or updates phpMyAdmin in ./phpmyadmin and serves it at phpmyadmin.test,
# from a Laravel Herd parked folder (macOS) or inside a Laravel Homestead box.
set -euo pipefail

DIR=phpmyadmin
VAGRANT_SCRIPTS=${VAGRANT_SCRIPTS:-/vagrant/scripts/}

sha256() {
    if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d ' ' -f 1
}

# Everything runs from here, so a half-downloaded `curl | bash` does nothing
main() {
    if [ -f "${VAGRANT_SCRIPTS}site-types/laravel.sh" ]; then # Homestead 9 (2019) and later
        MODE=homestead
        DB_HOST=localhost
        NO_PASSWORD=false
    elif command -v herd >/dev/null; then
        MODE=herd
        DB_HOST=127.0.0.1 # Herd's PHP has no default MySQL socket, so use TCP
        NO_PASSWORD=true  # root has none on DBngin and Herd Pro; Herd serves only this Mac
    else
        echo "Run this in a Herd parked folder, or inside a Homestead box." >&2
        exit 1
    fi

    # Replace ./phpmyadmin only if it's empty or an earlier phpMyAdmin (every release has a RELEASE-DATE-* file)
    if [ -e "$DIR" ] && [ -n "$(ls -A "$DIR")" ] && ! ls "$DIR"/RELEASE-DATE-* >/dev/null 2>&1; then
        echo "./$DIR exists and isn't phpMyAdmin. Move it away and run this again." >&2
        exit 1
    fi

    # From https://stackoverflow.com/a/59825964/5155484
    VERSION_INFO="$(curl -fsS 'https://www.phpmyadmin.net/home_page/version.txt')"
    LATEST_VERSION="$(echo "$VERSION_INFO" | head -n 1)"
    LATEST_VERSION_URL="$(echo "$VERSION_INFO" | tail -n 1)"
    # We want the .tar.gz version
    LATEST_VERSION_URL="${LATEST_VERSION_URL/.zip/.tar.gz}"

    TMP="$(mktemp -d)"
    NEW=".$DIR.new" # next to $DIR, so the final swap is a quick rename
    trap 'rm -rf "$TMP" "$NEW"' EXIT

    echo "Downloading phpMyAdmin $LATEST_VERSION ($LATEST_VERSION_URL)"
    curl -f -# "$LATEST_VERSION_URL" -o "$TMP/phpmyadmin.tar.gz"

    # phpMyAdmin publishes a checksum next to each download
    EXPECTED="$(curl -fsS "$LATEST_VERSION_URL.sha256" | cut -d ' ' -f 1)"
    if [ "$(sha256 "$TMP/phpmyadmin.tar.gz")" != "$EXPECTED" ]; then
        echo "The download is damaged (checksum mismatch). Nothing was changed." >&2
        exit 1
    fi

    rm -rf "$NEW"
    mkdir "$NEW"
    tar xzf "$TMP/phpmyadmin.tar.gz" -C "$NEW" --strip-components 1

    # Keep the config of an earlier install; otherwise create one with its own cookie secret
    if [ -f "$DIR/config.inc.php" ]; then
        cp -p "$DIR/config.inc.php" "$NEW/"
    else
        SECRET="$(openssl rand -hex 32)"
        cat > "$NEW/config.inc.php" <<EOF
<?php
\$cfg['blowfish_secret'] = sodium_hex2bin('$SECRET');
\$cfg['Servers'][1]['host'] = '$DB_HOST';
\$cfg['Servers'][1]['AllowNoPassword'] = $NO_PASSWORD;
\$cfg['PmaNoRelation_DisableWarning'] = true;
EOF
    fi

    rm -rf "$DIR"
    mv "$NEW" "$DIR"

    if [ "$MODE" = homestead ]; then
        sudo bash "${VAGRANT_SCRIPTS}create-certificate.sh" phpmyadmin.test
        sudo bash "${VAGRANT_SCRIPTS}site-types/laravel.sh" phpmyadmin.test "$(pwd)/$DIR" 80 443
        sudo service nginx reload
    fi

    echo "phpMyAdmin $LATEST_VERSION is ready in $(pwd)/$DIR"
    if [ "$MODE" = herd ]; then
        echo "Open http://phpmyadmin.test (if this folder isn't parked in Herd, run 'herd link' inside $DIR)"
    fi
}

main
