#!/bin/bash
# Build script for the lists

BUILDDIR="../build"
BASEFILE="../srclist/list.txt"
MAININDEX="$BUILDDIR/index/index.txt"

# CD to the script directory
cd "$(dirname "$0")"

# Recreate the build directory
rm $BUILDDIR -R; mkdir -p $BUILDDIR/scripts; mkdir -p $BUILDDIR/index

### Compile the lists
# Create the index file
echo "# Lists" > $MAININDEX

## Intermediate in build and Plaintext [ListName].txt for each list (starting with "# [" in the list) 
TEXT_LIST_GROUPS=$(grep -r "# \[" $BASEFILE | sed 's/.*# \[//g' | sed 's/\].*//g')
for TEXT_LIST_GROUP in $TEXT_LIST_GROUPS; do
    # Create the list file
    LIST_FILE="$BUILDDIR/$TEXT_LIST_GROUP.txt"
    # Add the list to the index
    echo "$TEXT_LIST_GROUP.txt" >> $MAININDEX

    echo "#$TEXT_LIST_GROUP" > $LIST_FILE
    # Add the list items, from BASEFILE from the Group "# [$TEXT_LIST_GROUP]" till next group "# ["
    START_GROUP=$(grep -n "# \[$TEXT_LIST_GROUP\]" $BASEFILE | cut -d: -f1)
    END_GROUP=$(grep -n "# \[" $BASEFILE | grep -A1 "# \[$TEXT_LIST_GROUP" | tail -n1 | cut -d: -f1)
    # IF NO END_GROUP, then till end of file
    if [ -z "$END_GROUP" ]; then
        END_GROUP=$(wc -l $BASEFILE | cut -d" " -f1)
    fi
    sed -n "$START_GROUP,$END_GROUP p" $BASEFILE | grep -v "# \[" >> $LIST_FILE  
done

## Create a .honeylist.php file
HONEYLIST_FILE="$BUILDDIR/.honeylist.php"
echo "<?php" > $HONEYLIST_FILE
echo "// This file is generated by the build script" >> $HONEYLIST_FILE
echo "// It contains the list of all Honeypot lists" >> $HONEYLIST_FILE
echo "" >> $HONEYLIST_FILE

#Have each list an a seperate array called $[TEXT_LIST_GROUP] and containing 4 arrays, starts,ends, exact and contains
#they hold the data from "$BUILDDIR/$TEXT_LIST_GROUP.txt", where lines starting with "#" are ignored, *[data] gets into starts, *[end] into ends and *[data]* into contains, the rest into exact
for TEXT_LIST_GROUP in $TEXT_LIST_GROUPS; do
    #make name of the array lowercase
    TEXT_LIST_GROUP_SAFE=$(echo $TEXT_LIST_GROUP | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    #remove spaces
    TEXT_LIST_GROUP_SAFE=$(echo $TEXT_LIST_GROUP_SAFE | tr -d ' ')
    #remove .
    TEXT_LIST_GROUP_SAFE=$(echo $TEXT_LIST_GROUP_SAFE | tr -d '.')
    #replace - with _
    TEXT_LIST_GROUP_SAFE=$(echo $TEXT_LIST_GROUP_SAFE | tr '-' '_')
    ##if # is in the line, remove it and everything after it
    line=$(echo $line | sed 's/#.*//')

    echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}'] = array();" >> $HONEYLIST_FILE
    echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['starts'] = array();" >> $HONEYLIST_FILE
    echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['ends'] = array();" >> $HONEYLIST_FILE
    echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['exact'] = array();" >> $HONEYLIST_FILE
    echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['contains'] = array();" >> $HONEYLIST_FILE
    while IFS= read -r line; do
        #remove newlines        
        line=$(echo $line | tr -d '\r\n')
        #remove alternate newlines
        line=$(echo $line | tr -d '\n')
        #remove comments
        if [[ $line == \#* ]]; then
            continue
        fi
        #if line is empty, skip
        if [[ -z "$line" ]]; then
            continue
        fi

        #check if line has a * at the start, remove it and add to ends array
        if [[ $line == \** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['ends'][] = \"$line\";" >> $HONEYLIST_FILE
        #check if line has a * at the end, remove it and add to starts array
        elif [[ $line == *\** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['starts'][] = \"$line\";" >> $HONEYLIST_FILE
        #check if line has a * at the start and end, remove them and add to contains array
        elif [[ $line == \** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['contains'][] = \"$line\";" >> $HONEYLIST_FILE
        #else add to exact array
        else
            echo "\$honeylist['${TEXT_LIST_GROUP_SAFE}']['exact'][] = \"$line\";" >> $HONEYLIST_FILE
        fi
    done <"$BUILDDIR/$TEXT_LIST_GROUP.txt"

    #add some newlines
    echo "" >> $HONEYLIST_FILE
done

#build default .htaccess file with -a flag
./build_htaccess.sh -a

## Create the README.md
README_FILE="README.md"
echo "# Lists" > $README_FILE
echo "This repository contains lists of various lists of scanned urls, backdoor files and other abused files. With this Lists you can scan your website for any malicious " >> $README_FILE
echo "files. (Not realy intended but a nice side effect) Select lists to use as "Honeypots" to block access to your website from malicious users." >> $README_FILE
echo "" >> $README_FILE
echo "## Lists" >> $README_FILE
for TEXT_LIST_GROUP in $TEXT_LIST_GROUPS; do
    #add a link to the list
    echo "- [$TEXT_LIST_GROUP](./build/$TEXT_LIST_GROUP.txt)" >> $README_FILE
done
echo "" >> $README_FILE
echo "## Usage" >> $README_FILE
echo "## scan.sh" >> $README_FILE
echo "Used to scan a website for files in the lists. " >> $README_FILE
echo "Helps you determine what lists you can use and maybe even finds some malicious files." >> $README_FILE
echo "" >> $README_FILE
echo "## build.sh" >> $README_FILE
echo "Is run as an Action in GitHub to build the lists. You can find the lists in the build directory." >> $README_FILE

echo "" >> $README_FILE
echo "## build_htaccess.sh " >> $README_FILE
echo "Used to build a .htaccess file for the lists." >> $README_FILE
echo "You can use this file to block access to your website from malicious users. " >> $README_FILE
echo "Using -a flag will build the .htaccess file with all lists, otherwise you can specify the lists you want to use." >> $README_FILE
echo "" >> $README_FILE

mv $README_FILE ../

#copy build_htaccess.sh to build directory
cp build_htaccess.sh $BUILDDIR/scripts/
#copy scan.sh to build directory
cp scan.sh $BUILDDIR/scripts/
#copy collect.sh to build directory
cp collect.sh $BUILDDIR/scripts/
#copy examples directory to build directory
cp -r examples $BUILDDIR/

# Done
exit 0