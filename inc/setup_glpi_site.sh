# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" == "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

GLPI_FOLDER_NAME="glpi_$GLPI_TAG"
GLPI_FOLDER_PATH="$WWW_DIR/$GLPI_FOLDER_NAME"
GLPI_ARCHIVE_FILENAME="glpi-$GLPI_VERSION.tgz"
GLPI_ARCHIVE_URL="https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/$GLPI_ARCHIVE_FILENAME"
if [ "$_LCL_VERBOSE_" == true ]; then
	echo -e "$BGreen""DEBUG$CRST: GLPI folder is $GLPI_FOLDER_PATH"
	echo -e "$BGreen""DEBUG$CRST: getting GLPI archive from $GLPI_ARCHIVE_URL"
fi

TAR_TAGS="-xzf"
# if [ "$_LCL_VERBOSE_" == true ]; then
# 	TAR_TAGS="-xzvf"
# fi
# Download and extract official archive
wget $GLPI_ARCHIVE_URL -O /tmp/$GLPI_ARCHIVE_FILENAME &&\
tar $TAR_TAGS /tmp/$GLPI_ARCHIVE_FILENAME -C $WWW_DIR &&\
mv $WWW_DIR/glpi $GLPI_FOLDER_PATH &&\
chown -R www-data:www-data $WWW_DIR &&\
echo "INFO: File extraction is successful"

mkdir -p /home/www-data/$GLPI_FOLDER_NAME
mv $GLPI_FOLDER_PATH/files /home/www-data/$GLPI_FOLDER_NAME
chown -R www-data:www-data /home/www-data

# initialize database
cat rss/install_glpi.sql \
	| sed "s/_VERSION_/$GLPI_TAG/g" \
	| sed "s/_SQL_USERNAME_/$SQL_USERNAME/g" \
	| sed "s/_SQL_PASSWORD_/$SQL_PASSWORD/g" \
	| mariadb
if [ "$_LCL_VERBOSE_" == true ]; then
	echo -e "$BGreen""DEBUG$CRST: Initialized database"
fi

# Building live version configuration
cat rss/apache_conf_template.txt \
	| sed "s/_SERVER_NAME_/glpi/g" \
	| sed "s/_SERVER_LOCAL_IP_/$SERVER_IP/g" \
	| sed "s/_PHP_VERSION_/$CURR_PHP_VER/g" \
	| sed "s/_WWW_DIR_/$WWW_DIR/g" \
	| sed "s/_GLPI_FOLDER_NAME_/$GLPI_FOLDER_NAME/g" \
	| sed "s/_GLPI_VERSION_/$GLPI_VERSION/g" \
	> /etc/apache2/sites-available/001-glpi.conf
if [ "$_LCL_VERBOSE_" == true ]; then
	echo -e "$BGreen""DEBUG$CRST: Built apache configuration"
fi

mkdir -p /home/www-data/$GLPI_FOLDER_NAME
cat rss/glpi/local_define.php | sed "s/_GLPI_FOLDER_NAME_/$GLPI_FOLDER_NAME/" > $GLPI_FOLDER_PATH/config/local_define.php
# setting http_only cookies
find /etc -name "php.ini" -exec sed -i 's/session.cookie_httponly.*/session.cookie_httponly = 1/g' {} \+

# Enable live version config
a2ensite 001-glpi.conf
