<?php

require __DIR__ . '/config.php';

header('Content-Type: text/plain; charset=UTF-8');
header('Cache-Control: no-store');

try {
    $database = mysqli_init();
    $database->options(MYSQLI_OPT_CONNECT_TIMEOUT, 2);
    $database->real_connect(Config::DB_HOST, Config::DB_USERNAME, Config::DB_PASSWORD, Config::DB_NAME);
    $database->query('SELECT 1');
    http_response_code(200);
    echo "ok\n";
} catch (Throwable $exception) {
    http_response_code(503);
    echo "unavailable\n";
}
