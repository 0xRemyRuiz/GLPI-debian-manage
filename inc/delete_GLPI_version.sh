source colors.sh

# standlone bypass for testing and reset only
if [ "$1" = "bypass" ]; then
	echo "$BYellow""WARNING$CRST bypass option forces deletion, press a key to continue"
	read -n 1 -s
	_LCL_VERBOSE_=false
	if [ "$2" == "-v" ]; then
		_LCL_VERBOSE_=true
	fi

	source inc/check_root.sh
	read -p "Enter GLPI version to delete: " GLPI_VERSION
	GLPI_TAG=$(echo "$GLPI_VERSION" | sed 's/\./_/g')
	if [ "$_LCL_VERBOSE_" == true ]; then
		echo "$BBlue""INFO$CRST: GLPI_TAG=$GLPI_TAG"
	fi
	systemctl stop apache2
fi

# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" == "" ]; then
	echo "$BRed""ERROR$CRST: script is not meant to be run alone exiting..."
	echo "$Blue""INFO$CRST: To bypass and force deletion use: $0 bypass or $0 bypass -v"
	exit 1
fi

GLPI_FOLDER_NAME="glpi_$GLPI_TAG"
GLPI_FOLDER_PATH="/var/www/html/$GLPI_FOLDER_NAME"

if [ "$_LCL_VERBOSE_" == true ]; then
	echo "$BGreen""DEBUG$CRST: Disabling site"
fi
a2dissite glpi-$GLPI_VERSION.conf
if [ "$_LCL_VERBOSE_" == true ]; then
	echo "$BGreen""DEBUG$CRST: Moving GLPI apache configuation and web folder to /tmp"
fi
mv /etc/apache2/sites-available/glpi-$GLPI_VERSION.conf /tmp
mv $GLPI_FOLDER_PATH /tmp

if [ "$1" = "bypass" ]; then
	read -p "$BYellow""WARNING$CRST: Confirm deleting mysql database glpi_$GLPI_TAG (type \"yes drop it\"): " _ASK_BYPASS_DROP_DB_
	if [ "$_ASK_BYPASS_DROP_DB_" != "yes drop it" ]; then
		echo "$Blue""INFO$CRST: NOT droping database glpi_$GLPI_TAG"
		systemctl start apache2
		exit 0
	fi
fi

if [ "$_LCL_VERBOSE_" == true ]; then
	echo "$BGreen""DEBUG$CRST: Deleting database glpi_$GLPI_TAG"
fi
echo "DROP DATABASE glpi_$GLPI_TAG;" | mariadb

if [ "$1" = "bypass" ]; then
	systemctl start apache2
fi

