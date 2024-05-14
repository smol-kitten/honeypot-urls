<?php

### SEMI TESTED ###

/**
 * Prepend this file using the prepend directive in php.ini or .user.ini
 * This file will run a default action if a request matches a specific path
 * loads the list from the server in a folder not accessible from the web (configurable but advised to do so)
 * 
 * NOT PRODUCTION READY
 */

// Configuration
$HL_blocklist = '/path/to/.honeylist.php';
$HL_defaultAction = 'fail2ban'; //404, 403, fail2ban(403 and block)
$HL_loadedLists = ['wordpress_main', 'wordpress_plugins', 'wordpress_like', 'common_paths', 'common_abused_files', 'common_leaks', 'common_files', 'common_folders', 'common_impersonation_folders', 'common_backdoors', 'common_backdoors_well_known'];

// Load the list of paths
require $HL_blocklist;

// Get the current request path
$HL_path = $_SERVER['REQUEST_URI'];

// Main
if (HL_checkPath($HL_path, $HL_loadedLists)) {
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
    global $honeylist;
    #list has $honeylist['listname'][type]
    #types are starts, ends, contains, exact
    foreach ($lists as $list) {
        foreach ($honeylist[$list] as $type => $names ) {
            foreach ($names as $item) {
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
 * Problematic with cloudflare if used using firewall rules
 * Use a appropriate fail2ban configuration including cloudflare support
 * @return void
 */
function HL_fail2ban() {
    // Add the IP to the fail2ban list
    //print error message to the log to trigger the fail2ban
    $msg = "Fail2Ban: " . $_SERVER['REMOTE_ADDR'] . " tried to access " . $_SERVER['REQUEST_URI'];
    error_log($msg);

    // block the request
    HL_403();
}

/**
 * 404 the request
 * @return void
 */
function HL_notFound() {
    http_response_code(404);
    exit;
}


