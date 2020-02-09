#!/bin/bash

set -euo pipefail

generate_settings()
{
  if [ -e "data/LocalSettings.php" ]; then
    cp data/LocalSettings.php .
  fi
  # If there is no LocalSettings.php, create one using maintenance/install.php
  if [ ! -e "LocalSettings.php" ]; then
    php maintenance/install.php \
      --confpath /var/www/html \
      --dbname "$MEDIAWIKI_DB_NAME" \
      --dbschema "$MEDIAWIKI_DB_SCHEMA" \
      --dbport "$MEDIAWIKI_DB_PORT" \
      --dbserver "$MEDIAWIKI_DB_HOST" \
      --dbtype "$MEDIAWIKI_DB_TYPE" \
      --dbuser "$MEDIAWIKI_DB_USER" \
      --dbpass "$MEDIAWIKI_DB_PASSWORD" \
      --installdbuser "$MEDIAWIKI_DB_USER" \
      --installdbpass "$MEDIAWIKI_DB_PASSWORD" \
      --server "$MEDIAWIKI_SITE_SERVER" \
      --scriptpath "" \
      --lang "$MEDIAWIKI_SITE_LANG" \
      --pass "$MEDIAWIKI_ADMIN_PASS" \
      "$MEDIAWIKI_SITE_NAME" \
      "$MEDIAWIKI_ADMIN_USER"

    # Append inclusion of /compose_conf/CustomSettings.php
    echo "@include('/conf/CustomSettings.php');" >> LocalSettings.php

    cp LocalSettings.php data/
  fi
}

mkdir -p /var/www/html/{data,images}
chown www-data /var/www/html/{data,images}

export -f generate_settings
su www-data -s /bin/bash -c "bash -c generate_settings"

exec docker-php-entrypoint apache2-foreground
