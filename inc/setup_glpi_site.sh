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
chown -R www-data $GLPI_FOLDER_PATH &&\
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

# Building site configuration
cat rss/apache_conf_template.txt \
| sed "s/_SERVER_NAME_/$SERVER_NAME/g" \
| sed "s/_SERVER_LOCAL_IP_/$SERVER_IP/g" \
| sed "s/_PHP_VERSION_/$CURR_PHP_VER/g" \
| sed "s/_GLPI_FOLDER_NAME_/$GLPI_FOLDER_NAME/g" \
| sed "s/_URL_/\/glpi_$GLPI_TAG/g" \
> /etc/apache2/sites-available/glpi-$GLPI_VERSION.conf

# Enable site config
a2ensite glpi-$GLPI_VERSION.conf

# Building live version configuration
cp /etc/apache2/sites-available/001-glpi.conf /etc/apache2/sites-available/glpi-old.conf 2> /dev/null
cat rss/apache_conf_template.txt \
| sed "s/_SERVER_NAME_/$SERVER_NAME/g" \
| sed "s/_SERVER_LOCAL_IP_/$SERVER_IP/g" \
| sed "s/_PHP_VERSION_/$CURR_PHP_VER/g" \
| sed "s/_GLPI_FOLDER_NAME_/$GLPI_FOLDER_NAME/g" \
| sed "s/RewriteBase _URL_\//RewriteBase _URL_/g" \
| sed "s/_URL_/\//g" \
> /etc/apache2/sites-available/001-glpi.conf

# adding return character
echo "" >> /etc/apache2/sites-available/001-glpi.conf
# adding live version tag
echo "# live version: $GLPI_VERSION" >> /etc/apache2/sites-available/001-glpi.conf

cd $GLPI_FOLDER_PATH
yes | sudo -u www-data php bin/console db:install -d glpi_$GLPI_TAG -u $SQL_USERNAME -p $SQL_PASSWORD

# Enable live version config
a2ensite 001-glpi.conf
