# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" = "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

if [ "$_LCL_VERBOSE_" = true ]; then
	echo "DEBUG: Checking if script is run under root"
fi
if [ $(whoami) != "root" ]; then
	echo "Authentification root user"; su root
fi
if [ $(whoami) != "root" ]; then
	echo "Must be root to execute script"; exit 1
fi
