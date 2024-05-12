<?php

### UNTESTED ###

/**
 * Prepend this file using the prepend directive in php.ini or .user.ini
 * This file will run a default action if a request matches a specific path
 * loads the list from the server in a folder not accessible from the web (configurable but advised to do so)
 * 
 * NOT PRODUCTION READY
 */

// Configuration
$HL_blocklist = '/path/to/.honeylist.php';
$HL_defaultAction = '403'; //404, 403, fail2ban
$HL_loadedLists = ['list1', 'list2', 'list3'];

// Load the list of paths
$HL_paths = require $HL_blocklist;

// Get the current request path
$HL_path = $_SERVER['REQUEST_URI'];

// Main
if (HL_checkPath($HL_path, $HL_paths)) {
    if ($HL_defaultAction === '403') {
        HL_403();
    } elseif ($HL_defaultAction === 'fail2ban') {
        HL_fail2ban();
    } elseif ($HL_defaultAction === '404') {
        HL_notFound();
    }
}

// Functions
/**
 * Check if the path is in the list
 * @param string $path
 * @param array $lists
 * @return bool
 */
function HL_checkPath($path, $lists) {
    #list has $honeylist['listname'][type]
    #types are starts, ends, contains, exact
    foreach ($lists as $list) {
        foreach ($list as $type => $list) {
            foreach ($list as $item) {
                if ($type === 'starts' && strpos($path, $item) === 0) {
                    return true;
                }
                if ($type === 'ends' && substr($path, -strlen($item)) === $item) {
                    return true;
                }
                if ($type === 'contains' && strpos($path, $item) !== false) {
                    return true;
                }
                if ($type === 'exact' && $path === $item) {
                    return true;
                }
            }
        }
    }
}


/**
 * Block the request
 * @return void
 */
function HL_403() {
    http_response_code(403);
    exit;
}

/**
 * Fail2Ban the request
 * @return void
 */
function HL_fail2ban() {
    // Add the IP to the fail2ban list
    // block the request
    HL_403();
    //print error message to the log to trigger the fail2ban
    $msg = "Fail2Ban: " . $_SERVER['REMOTE_ADDR'] . " tried to access " . $_SERVER['REQUEST_URI'];
    error_log($msg);
}

/**
 * 404 the request
 * @return void
 */
function HL_notFound() {
    http_response_code(404);
    exit;
}


