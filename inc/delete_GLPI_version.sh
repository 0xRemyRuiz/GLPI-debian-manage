# standlone bypass for testing and reset only
if [ "$1" = "bypass" ]; then
	echo "WARNING bypass option forces deletion, press a key to continue"
	read -n 1 -s
	_LCL_VERBOSE_=false
	if [ "$2" == "-v" ]; then
		_LCL_VERBOSE_=true
	fi

	source inc/check_root.sh
	read -p "Enter GLPI version to delete: " GLPI_VERSION
	GLPI_TAG=$(echo "$GLPI_VERSION" | sed 's/_/-/g')
fi

# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" = "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."
	echo "INFO: To bypass and force deletion use: $0 bypass or $0 bypass -v"
	exit 1
fi

GLPI_FOLDER_NAME="glpi_$GLPI_TAG"
GLPI_FOLDER_PATH="/var/www/html/$GLPI_FOLDER_NAME"

a2dissite glpi-$GLPI_TAG.conf
rm /etc/apache2/sites-available/glpi-$GLPI_TAG.conf
rm -rf $GLPI_FOLDER_PATH

