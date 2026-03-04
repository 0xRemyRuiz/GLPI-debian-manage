<?php

	// Remove Notice/Alert from session configuration 
	// ini_set('session.cookie_secure', 1);
	ini_set('session.cookie_httponly', 1);

	define('GLPI_VAR_DIR', '/home/www-data/_GLPI_FOLDER_NAME_/files');
	define('GLPI_DOC_DIR', GLPI_VAR_DIR);
