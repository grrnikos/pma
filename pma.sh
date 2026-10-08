#!/bin/bash
set -euo pipefail

sha256() {
    if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d ' ' -f 1
}

# Everything runs from here, so a half-downloaded `curl | bash` does nothing
main() {
    # From https://stackoverflow.com/a/59825964/5155484
    VERSION_INFO="$(curl -fsS 'https://www.phpmyadmin.net/home_page/version.txt')"
    LATEST_VERSION="$(echo "$VERSION_INFO" | head -n 1)"
    LATEST_VERSION_URL="$(echo "$VERSION_INFO" | tail -n 1)"
    # We want the .tar.gz version
    LATEST_VERSION_URL="${LATEST_VERSION_URL/.zip/.tar.gz}"

    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    echo "Downloading phpMyAdmin $LATEST_VERSION ($LATEST_VERSION_URL)"
    curl -f -# "$LATEST_VERSION_URL" -o "$TMP/phpmyadmin.tar.gz"

    # phpMyAdmin publishes a checksum next to each download
    EXPECTED="$(curl -fsS "$LATEST_VERSION_URL.sha256" | cut -d ' ' -f 1)"
    if [ "$(sha256 "$TMP/phpmyadmin.tar.gz")" != "$EXPECTED" ]; then
        echo "The download is damaged (checksum mismatch). Nothing was changed." >&2
        exit 1
    fi

    mkdir phpmyadmin
    tar xzf "$TMP/phpmyadmin.tar.gz" -C phpmyadmin --strip-components 1

    VAGRANT_SCRIPTS=${VAGRANT_SCRIPTS:-/vagrant/scripts/}

    CMD=${VAGRANT_SCRIPTS}site-types/laravel.sh
    CMD_CERT=${VAGRANT_SCRIPTS}create-certificate.sh

    if [ ! -f "$CMD" ]; then
        # Fallback for older Homestead versions
        CMD=${VAGRANT_SCRIPTS}serve.sh
    else
        # Create an SSL certificate
        sudo bash "$CMD_CERT" phpmyadmin.test
    fi

    sudo bash "$CMD" phpmyadmin.test "$(pwd)/phpmyadmin" 80 443

    sudo service nginx reload
}

main
