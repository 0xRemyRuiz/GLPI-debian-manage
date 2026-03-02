# NOTE: This script is not meant to be executed alone
if [ "$_LCL_VERBOSE_" = "" ]; then
	echo "ERROR: script is not meant to be run alone exiting..."; exit 1
fi

# Getting last stable GLPI version
GLPI_VERSION=$(\
	curl -s https://api.github.com/repos/glpi-project/glpi/tags \
	| grep -E '\"name\": \"[0-9]+\.[0-9]+\.[0-9]+\"' \
	| head -n 1 \
	| grep -Eo '([0-9]+\.?)+')

if [ "$_LCL_VERBOSE_" = true ]; then
	echo "DEBUG: GLPI version=$GLPI_VERSION"
fi
if [ "$GLPI_VERSION" == "" ]; then
	echo "ERROR: GLPI version not found"; exit 1
fi

GLPI_TAG="$(echo $GLPI_VERSION | sed 's/\./_/g')"
if [ "$_LCL_VERBOSE_" = true ]; then
	echo "DEBUG: GLPI tag=$GLPI_TAG"
fi

CURR_PHP_VER=$(php -v | grep -Eo 'PHP ([0-9]+\.)+' | grep -Eo '[0-9]+\.[0-9]+' | tr -d '\n')
if [ "$_LCL_VERBOSE_" = true ]; then
	echo "DEBUG: PHP version=$CURR_PHP_VER"
fi
