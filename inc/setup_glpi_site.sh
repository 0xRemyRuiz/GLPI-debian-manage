# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" == "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

GLPI_FOLDER_NAME="glpi_$GLPI_TAG"
GLPI_FOLDER_PATH="/var/www/html/$GLPI_FOLDER_NAME"
GLPI_ARCHIVE_FILENAME="glpi-$GLPI_VERSION.tgz"
GLPI_ARCHIVE_URL="https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/$GLPI_ARCHIVE_FILENAME"
if [ "$_LCL_VERBOSE_" == true ]; then
	echo "DEBUG: GLPI folder is $GLPI_FOLDER_PATH"
	echo "DEBUG: getting GLPI archive from $GLPI_ARCHIVE_URL"
fi

TAR_TAGS="-xzf"
if [ "$_LCL_VERBOSE_" == true ]; then
	TAR_TAGS="-xzvf"
fi
# Download and extract official archive
wget $GLPI_ARCHIVE_URL -O /tmp/$GLPI_ARCHIVE_FILENAME &&\
tar $TAR_TAGS /tmp/$GLPI_ARCHIVE_FILENAME -C /var/www/html &&\
mv /var/www/html/glpi $GLPI_FOLDER_PATH &&\
chown -R www-data:www-data /var/www/html &&\
echo "INFO: File extraction is successful"

# initialize database
if [ "$_LCL_VERBOSE_" == true ]; then
	echo "DEBUG: Reinitializing database"
fi
cat rss/install_glpi.sql \
| sed "s/_VERSION_/$GLPI_TAG/g" \
| sed "s/_SQL_USERNAME_/$SQL_USERNAME/g" \
| sed "s/_SQL_PASSWORD_/$SQL_PASSWORD/g" \
| mariadb

# Building live version configuration
cat rss/apache_conf_template.txt \
| sed "s/_SERVER_NAME_/glpi/g" \
| sed "s/_SERVER_LOCAL_IP_/$SERVER_IP/g" \
| sed "s/_PHP_VERSION_/$CURR_PHP_VER/g" \
| sed "s/_GLPI_FOLDER_NAME_/$GLPI_FOLDER_NAME/g" \
| sed "s/_GLPI_VERSION_/$GLPI_VERSION/g" \
> /etc/apache2/sites-available/001-glpi.conf

cp rss/glpi/local_define.php $GLPI_FOLDER_PATH/config/
# setting http_only cookies
sudo find /etc -name "php.ini" -exec sed -i 's/session.cookie_httponly.*/session.cookie_httponly = 1/g' {} \+

# Enable live version config
a2ensite 001-glpi.conf
