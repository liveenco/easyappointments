#!/bin/sh
set -eu

: "${PORT:=8080}"
export PORT
umask 027
: "${BASE_URL:?BASE_URL is required}"
: "${DB_HOST:?DB_HOST is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USERNAME:?DB_USERNAME is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${EA_ENCRYPTION_KEY:?EA_ENCRYPTION_KEY is required}"

# Set permissions on the mounted volume and its application directories.
storage_root=/var/www/html/storage
for directory in "$storage_root" "$storage_root/backups" "$storage_root/cache" \
    "$storage_root/logs" "$storage_root/sessions" "$storage_root/uploads"; do
    install -d -m 0750 -o www-data -g www-data "$directory"
    if ! runuser -u www-data -- test -w "$directory"; then
        printf 'Storage directory is not writable by www-data: %s\n' "$directory" >&2
        exit 1
    fi
done

access_file=/etc/apache2/easyappointments-access.conf
if [ "${EA_SETUP_MODE:-protected}" = public ]; then
    printf '%s\n' 'Require all granted' > "$access_file"
else
    : "${EA_SETUP_PASSWORD:?EA_SETUP_PASSWORD is required in protected mode}"
    printf '%s\n' "$EA_SETUP_PASSWORD" | htpasswd -i -c -B /etc/apache2/easyappointments.htpasswd setup
    chgrp www-data /etc/apache2/easyappointments.htpasswd
    chmod 0640 /etc/apache2/easyappointments.htpasswd
    cat > "$access_file" <<'APACHE'
AuthType Basic
AuthName "Liveen setup"
AuthBasicProvider file
AuthUserFile /etc/apache2/easyappointments.htpasswd
Require valid-user
APACHE
fi

# Normalize Apache modules at startup as well as at build time.
a2dismod mpm_event mpm_worker
a2enmod mpm_prefork
apache2ctl configtest

exec apache2-foreground
