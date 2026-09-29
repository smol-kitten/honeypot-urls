#!/bin/bash

# Collects 404 data from the log files to find out which URLs are scanned

# Get all weblog files
SITES=$(ls /etc/apache2/sites-enabled/* /etc/nginx/sites-enabled/*)
WEBLOGS=()
# Loop through the sites and get webroots
for SITE in ${SITES[@]}; do
    # Get the webroot
    WEBLOGS_LOCAL=$(grep -r " CustomLog" $SITE | sed 's/.* CustomLog //g' | sed 's/\"//g')
    for WEBLOG_LOCAL in $WEBLOGS_LOCAL; do
        #Add the webroot to the list if not already in it
        if [[ ! " ${WEBLOGS[@]} " =~ " ${WEBLOG_LOCAL} " ]]; then
            WEBLOGS+=("$WEBLOG_LOCAL")
        fi
    done
done

#Replace ${APACHE_LOG_DIR}, assuming it is /var/log/apache2
WEBLOG_C=()
for WEBLOG in ${WEBLOGS[@]}; do
    WEBLOG_C+=($(echo $WEBLOG | sed 's/\${APACHE_LOG_DIR}/\/var\/log\/apache2/g'))
done

WEBLOGS=("${WEBLOG_C[@]}")

rm -f 404.log

#Get all the 404s
for WEBLOG in ${WEBLOGS[@]}; do
    echo "Processing $WEBLOG"
    #Get all the 404s
    if [ ! -f $WEBLOG ]; then
        echo "File $WEBLOG does not exist"
        continue
    fi
    grep -r " 404 " $WEBLOG | awk '{print $7}' | sort | uniq -c | sort -nr >>404.log
done


#Get only paths
# looks like 162.158.203.22 - - [10/May/2024:00:34:38 +0200] "POST /phpmyadmin/index.php?route=/table/replace HTTP/2.0" 200 2604 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
cat 404.log | awk '{print $2}' | awk -F" " '{print $1}' > 404.log.tmp
mv 404.log.tmp collected/scanned.log

#Split / and sort and count most common to least common
cat collected/scanned.log | awk -F"/" '{print $2}' | sort | uniq -c | sort -nr > collected/keywords.log