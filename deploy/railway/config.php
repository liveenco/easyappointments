<?php

define('EA_BASE_URL', getenv('BASE_URL'));
define('EA_DB_HOST', getenv('DB_HOST'));
define('EA_DB_NAME', getenv('DB_NAME'));
define('EA_DB_USERNAME', getenv('DB_USERNAME'));
define('EA_DB_PASSWORD', getenv('DB_PASSWORD'));
define('ENCRYPTION_KEY', getenv('EA_ENCRYPTION_KEY'));

class Config
{
    const BASE_URL = EA_BASE_URL;
    const LANGUAGE = 'spanish';
    const DEBUG_MODE = false;
    const DB_HOST = EA_DB_HOST;
    const DB_NAME = EA_DB_NAME;
    const DB_USERNAME = EA_DB_USERNAME;
    const DB_PASSWORD = EA_DB_PASSWORD;
}
