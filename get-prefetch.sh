#!/bin/bash
# 
# get-prefetch.sh
# Bash script to compute filename, size, and sha1.
# Useful when building BigFix prefetch blocks.
# 
# atlauren@uci.edu
# 2011-11-21 First publish
# 2025-04-28 add parameter-formatted output
# 2026-08-27 separate output sections by positional parameter; theName always output
# 2026-09-02 add --clip to copy header-free content to the clipboard
#
# https://github.com/atlauren/bigfix/get-prefetch.sh
# 

doHelp () {
    echo "usage: get-prefetch.sh [--basic|--params|--json|--all] [--clip] /path/to/file*"
    echo "  (theName is always output)"
    echo "  --basic   output basic info (default)"
    echo "  --params  output BigFix parameter block"
    echo "  --json    output JSON blob"
    echo "  --all     output all sections"
    echo "  --clip    also copy the content blocks (no headers) to the clipboard"
}

# parse flags; basic is default
outputMode="basic"
useClip="false"
while [[ "$1" == --* ]]; do
    case "$1" in
        --basic)  outputMode="basic" ;;
        --params) outputMode="params" ;;
        --json)   outputMode="json" ;;
        --all)    outputMode="all" ;;
        --clip)   useClip="true" ;;
        *)        doHelp; exit ;;
    esac
    shift
done

clipBuffer=""

# header line: never copied to the clipboard
hdr () {
    echo "$1"
}

# content line: copied to the clipboard when --clip is set
out () {
    echo -e "$1"
    if [[ "$useClip" == "true" ]]; then
        clipBuffer+="$( echo -e "$1" )"$'\n'
    fi
}

#vars
files="$@"

if [[ -z $files ]]; then
    doHelp
    exit
fi

for file in $files
do

    if [[ -f $file ]]; then

        theName=$( basename $(stat -f %N $file) )
        theSize=$( stat -f %z $file )
        theSha=$( shasum -a 1 $file | awk '{print $1}' )

        # theName is always output
        hdr "*** $theName ***"

        if [[ "$outputMode" == "basic" || "$outputMode" == "all" ]]; then
            hdr "  ** BASIC **"
            out "  theName = $theName"
            out "  theSize = $theSize"
            out "  theSha  = $theSha"
        fi

        if [[ "$outputMode" == "params" || "$outputMode" == "all" ]]; then
            hdr "  ** PARAMETERS **"
            out '\t'"parameter \"theFile\" = \"$theName\""
            out '\t'"parameter \"theSha1\" = \"$theSha\""
            out '\t'"parameter \"theSize\" = \"$theSize\""
            out '\t'"parameter \"theFolder\" = \"{preceding text of last \".\" of following text of first \"_\" of (parameter \"theFile\")}\""
        fi

        if [[ "$outputMode" == "json" || "$outputMode" == "all" ]]; then
            hdr "  ** JSON **"
            out "  {"
            out "    \"filename\": \"$theName\","
            out "    \"size\": $theSize,"
            out "    \"sha1\": \"$theSha\""
            out "  }"
        fi

    else 
    
        echo "File \"$file\" does not exist."	
        doHelp
                
    fi

done

if [[ "$useClip" == "true" ]]; then
    printf '%s' "$clipBuffer" | pbcopy
fi
