#!/bin/bash
# Scan script for the lists
# Finds files from the lists ind your apache/nginx folders

#Arrays of webroots and matches and honeyfiles
WEBROOTS=()
MATCHES=()
HONEYFILES=()

LISTS_DIR="build"
# Get all the lists (.txt files) in the build directory
LISTS=$(ls $LISTS_DIR/*.txt)

# Get all the active sites in apache/nginx
SITES=$(ls /etc/apache2/sites-enabled/* /etc/nginx/sites-enabled/*)

#Debug add *index.php to the HONEYFILES
#HONEYFILES="$HONEYFILES *index.php"

# Loop through the sites and get webroots
for SITE in $SITES; do
    # Get the webroot
    WEBROOTS_LOCAL=$(grep -r "DocumentRoot" $SITE | sed 's/.*DocumentRoot //g' | sed 's/\"//g')
    # Check if the webroot exists
    for WEBROOT_LOCAL in $WEBROOTS_LOCAL; do
        if [ -d "$WEBROOT_LOCAL" ]; then            
            #Add the webroot to the list if not already in it
            if [[ ! " ${WEBROOTS[@]} " =~ " ${WEBROOT_LOCAL} " ]]; then
                #echo "Found webroot: $WEBROOT_LOCAL"
                WEBROOTS+=("$WEBROOT_LOCAL")
            fi
        fi
    done
done

# Load the lists
for LIST in $LISTS; do
    LIST_NAME=$(basename $LIST)
    #if index.txt, skip
    if [[ $LIST_NAME == "index.txt" ]]; then
        continue
    fi

    #load the list into the HONEYFILES
    HONEYFILES+=($(cat $LIST))
done

#Print info which directories are scanned
WR_COUNT=${#WEBROOTS[@]}
echo "Scanning the following directories: ($WR_COUNT)"
for WEBROOT in ${WEBROOTS[@]}; do
    echo $WEBROOT
done

MATCHES=()
for WEBROOT in ${WEBROOTS[@]}; do
    #Progress report in X/Y
    WR_COUNTER=$((WR_COUNTER+1))
    echo "Scanning $WEBROOT ($WR_COUNTER/$WR_COUNT)"
    for HONEYFILE in ${HONEYFILES[@]}; do
        #remove the * from the file
        TYPE=f
        HONEYFILEBASE=$HONEYFILE

        #remove whitespaces
        HONEYFILEBASE=$(echo $HONEYFILEBASE | tr -d ' ')
        #remove tabs
        HONEYFILEBASE=$(echo $HONEYFILEBASE | tr -d '\t')
        #remove newlines
        HONEYFILEBASE=$(echo $HONEYFILEBASE | tr -d '\n\r')
        #remove alternate newlines
        HONEYFILEBASE=$(echo $HONEYFILEBASE | tr -d '\n')
        #rempve carriage returns
        HONEYFILEBASE=$(echo $HONEYFILEBASE | tr -d '\r')
        #remove comments
        if [[ $HONEYFILEBASE == \#* ]]; then
            continue
        fi
        if [[ -z "$HONEYFILEBASE" ]]; then
            continue
        fi

        FILES=$(find $WEBROOT -type $TYPE -wholename $HONEYFILEBASE)
       
        #if files is empty, skip
        if [[ -z "$FILES" ]]; then
            continue
        fi
    
        for FILE in ${FILES[@]}; do
            #remove * from the HONEYFILEBASE
            HONEYFILEBASE=$(echo $HONEYFILEBASE | sed 's/\*//g')
            #if honeyfile has * at the start, check if honeyfile ends with the file
            if [[ $HONEYFILE == \** ]]; then
                if [[ $FILE == *$HONEYFILEBASE ]]; then
                    MATCHES+=("$FILE")
                    echo "$FILE Ends with $HONEYFILEBASE"
                fi
            #if honeyfile has * at the end, check if honeyfile starts with the file
            elif [[ $HONEYFILE == *\** ]]; then
                if [[ $FILE == $HONEYFILEBASE* ]]; then
                    MATCHES+=("$FILE")
                    echo "$FILE Starts with $HONEYFILEBASE"
                fi
            #if honeyfile has * at the start and end, check if honeyfile contains the file
            elif [[ $HONEYFILE == \** ]]; then
                if [[ $FILE == *$HONEYFILEBASE* ]]; then
                    MATCHES+=("$FILE")
                    echo "$FILE Contains $HONEYFILEBASE"
                fi
            #else check if the file is exactly the same
            else
                if [[ $FILE == $HONEYFILEBASE ]]; then
                    MATCHES+=("$FILE")
                    echo "$FILE Exact $HONEYFILEBASE"
                fi
            fi            
        done
    done
done
echo "Matches: ${MATCHES[@]}"