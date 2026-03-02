# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" = "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

# TODO: add a loop check here
read -p "Enter SQL username: " SQL_USERNAME
read -p "Enter SQL password: " SQL_PASSWORD
