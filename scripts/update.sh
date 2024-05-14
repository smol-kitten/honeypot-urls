#!/bin/bash
#This scipt can update the lists from the latest build
#-s list1,list2,list3 to update only the specified lists
#-h help
#-a to update all lists
#-l to list all available lists
#-o to specify the output directory

OUTDIR=""
BASEINDEX="https://github.com/smol-kitten/honeypot-urls/releases/download/auto-release-index/index.txt"
BASELISTS="https://github.com/smol-kitten/honeypot-urls/releases/download/auto-release/"

#curl dislikes the urls so use wget to tmp file and then read it
function wcurl {
    wget -q -O - $1
}


while getopts ":s:hal" opt; do

    #if opt not set but option is, set opt to optarg
    if [ $opt == ":" ]; then
        opt=$OPTARG
    fi

    case ${opt} in
        s )
            if [[ $OPTARG == \#* ]]; then
                echo "no lists to update set"
                continue
            fi
            #Update only the specified lists
            echo "Updating only the specified lists"
            LISTS=$(echo $OPTARG | tr "," "\n")
            ;;
        h )
            #Help
            echo "This script can update the lists from the latest build"
            echo "-s list1,list2,list3 to update only the specified lists"
            echo "-h help"
            echo "-a to update all lists"
            echo "-l to list all available lists"
            echo "-o to specify the output directory"
            exit 0
            ;;
        a )
            #Update every list
            echo "Updating all lists"
            LISTS=$(wcurl $BASEINDEX)
            ;;
        l )
            #List all available lists
            LISTS=$(wcurl $BASEINDEX)
            echo $LISTS
            exit 0
            ;;
        \? )
            echo "Invalid Option: $OPTARG" 1>&2
            exit 1
            ;;
    esac
done

#shift $((OPTIND -1))

#If no output directory, use the current directory
if [ -z "$OUTDIR" ]; then
    OUTDIR="./"
fi
#if the output directory does not end with a /, add it
if [[ ! "$OUTDIR" == */ ]]; then
    OUTDIR="$OUTDIR/"
fi

#If  ${LISTS[@]} contains nothing, ask for the list to update
if [ -z "${LISTS}" ]; then
    #Display the available lists
    LISTS=$(wcurl $BASEINDEX)
    echo "Available lists:"
    echo $LISTS
    echo ""
    #Ask for the list to update
    echo "Which list do you want to update?"
    read -r LISTS
fi

#Update the lists
for LIST in $LISTS; do
    #if starts with a #, skip
    if [[ $LIST == \#* ]]; then
        continue
    fi

    echo "Updating $LIST"
    wget -q -O $OUTDIR$LIST $BASELISTS/$LIST
done

#Done
echo "Done"
exit 0
