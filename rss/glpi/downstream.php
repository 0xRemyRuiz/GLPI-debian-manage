<?php
define('GLPI_CONFIG_DIR', '/etc/glpi-_VERSION_/');

if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
   require_once GLPI_CONFIG_DIR . '/local_define.php';
}