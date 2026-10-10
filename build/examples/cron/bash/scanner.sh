#!/bin/bash
# Scans the webroots for 404s, from those 404s it tries to find honeyfiles, if it finds honeyfiles it logs them to /var/log/honeyfiles.log
# Example "[05:05:05 2024-05-10] Fail2Ban: <host> /var/www/html/wordpress/wp-content/plugins/akismet/index.php"
#Lockfile in /tmp/honeyfiles.lock to prevent multiple instances