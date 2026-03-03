# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" = "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

# read -p "Enter Server name: " SERVER_NAME
# if [ "$SERVER_NAME" == "" ]; then
# 	SERVER_NAME=localhost
# fi
read -p "Enter Server local ip: " SERVER_IP
if [ "$(ipcalc $SERVER_IP)" != "" ]; then
	echo "WARNING: entered ip is not valid default is set to 127.0.0.1"
	SERVER_IP="127.0.0.1"
fi

