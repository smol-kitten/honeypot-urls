#!/bin/bash
# Build script for the lists

# Permutations of the lists to make .htaccess files for blocking
BUILD_DIR="../build"
# Create the .htaccess file

#-h flag
if [[ $1 == "-h" ]]; then
    echo "Builds a .htaccess file for blocking the Requests based on the lists in the build directory"
    echo "Usage: $0 [-a]"
    echo "  -a: Use all lists"
    echo "  -h: Show this help"
    echo "  No arguments: Ask for the list to use interactively"
    exit 0
fi

# Get all the lists (.txt files) in the build directory
LISTS=$(ls $BUILD_DIR/*.txt)

#make a list of all the lists and present to user like [0] list1.txt\n [1] list2.txt
LISTS_ARRAY=()
LISTS_ARRAY_COUNTER=0
for LIST in $LISTS; do
    LIST_NAME=$(basename $LIST)
    #if index.txt, skip
    if [[ $LIST_NAME == "index.txt" ]]; then
        continue
    fi
    LISTS_ARRAY+=($LIST_NAME)
    if [[ $1 != "-a" ]]; then
        echo "[$LISTS_ARRAY_COUNTER] $LIST_NAME"
    fi
    LISTS_ARRAY_COUNTER=$((LISTS_ARRAY_COUNTER+1))
done

# Ask the user which list to use allow , separated values to use multiple lists
if [[ $LISTS_ARRAY_COUNTER -eq 0 ]]; then
    echo "No lists found in $BUILD_DIR"
    exit 1
fi

#has -a flag do all, else ask for list
#echo "Which list do you want to use? (0-$(($LISTS_ARRAY_COUNTER-1)))"
#read -r LIST_CHOICE
#LIST_CHOICE_ARRAY=($(echo $LIST_CHOICE | tr "," "\n"))  
if [[ $1 == "-a" ]]; then
    LIST_CHOICE_ARRAY=($(seq 0 $(($LISTS_ARRAY_COUNTER-1))))
else
    echo "Which list do you want to use? (0-$(($LISTS_ARRAY_COUNTER-1)))"
    read -r LIST_CHOICE
    LIST_CHOICE_ARRAY=($(echo $LIST_CHOICE | tr "," "\n"))  
fi

# Create the .htaccess file for the selected lists, make a base and loop through the lists and append to the base
HTACCESS_FILE="$BUILD_DIR/.htaccess"
echo "# Honeypot lists" >$HTACCESS_FILE
echo "RewriteEngine On" >>$HTACCESS_FILE
echo "RewriteBase /" >>$HTACCESS_FILE
echo "" >>$HTACCESS_FILE

#foreach list, add the rules to the .htaccess file
for LIST_CHOICE in ${LIST_CHOICE_ARRAY[@]}; do
    LIST_CHOICE_FILE="${LISTS_ARRAY[$LIST_CHOICE]}"
    echo "# $LIST_CHOICE_FILE" >>$HTACCESS_FILE
    while IFS= read -r line; do
        if [[ $line == \#* ]]; then
            continue
        fi
        #remove newlines 
        line=$(echo $line | tr -d '\r\n')
        #remove alternate newlines
        line=$(echo $line | tr -d '\n')
        #if # is in the line, remove it and everything after it
        line=$(echo $line | sed 's/#.*//')
        #if line is empty, skip
        if [[ -z "$line" ]]; then
            continue
        fi

        #check if line has a * at the start, remove it and add to ends array
        if [[ $line == \** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "RewriteRule ^$line$ - [F,L]" >>$HTACCESS_FILE
        #check if line has a * at the end, remove it and add to starts array
        elif [[ $line == *\** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "RewriteRule ^$line.* - [F,L]" >>$HTACCESS_FILE
        #check if line has a * at the start and end, remove them and add to contains array
        elif [[ $line == \** ]]; then
            line=$(echo $line | sed 's/\*//')
            echo "RewriteRule .*${line}.* - [F,L]" >>$HTACCESS_FILE
        #else add to exact array
        else
            echo "RewriteRule .*${line}$ - [F,L]" >>$HTACCESS_FILE
        fi
    done <"$BUILD_DIR/$LIST_CHOICE_FILE"
    echo "" >> $HTACCESS_FILE
done

mv $HTACCESS_FILE $BUILD_DIR/examples/.htaccess

exit 0


    
