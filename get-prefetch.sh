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
#
# https://github.com/atlauren/bigfix/get-prefetch.sh
# 

doHelp () {
    echo "usage: get-prefetch.sh [--basic|--params|--json|--all] /path/to/file*"
    echo "  (theName is always output)"
    echo "  --basic   output basic info (default)"
    echo "  --params  output BigFix parameter block"
    echo "  --json    output JSON blob"
    echo "  --all     output all sections"
}

# parse output mode flag; basic is default
outputMode="basic"
if [[ "$1" == "--basic" ]]; then
    outputMode="basic"
    shift
elif [[ "$1" == "--params" ]]; then
    outputMode="params"
    shift
elif [[ "$1" == "--json" ]]; then
    outputMode="json"
    shift
elif [[ "$1" == "--all" ]]; then
    outputMode="all"
    shift
fi

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
        echo "*** $theName ***"

        if [[ "$outputMode" == "basic" || "$outputMode" == "all" ]]; then
            echo "  ** BASIC **"
            echo "  theName = $theName"
            echo "  theSize = $theSize"
            echo "  theSha  = $theSha"
        fi

        if [[ "$outputMode" == "params" || "$outputMode" == "all" ]]; then
            echo "  ** PARAMETERS **"
            echo -e '\t'"parameter \"theFile\" = \"$theName\""
            echo -e '\t'"parameter \"theSha1\" = \"$theSha\""
            echo -e '\t'"parameter \"theSize\" = \"$theSize\""
        fi

        if [[ "$outputMode" == "json" || "$outputMode" == "all" ]]; then
            echo "  ** JSON **"
            echo "  {"
            echo "    \"filename\": \"$theName\","
            echo "    \"size\": $theSize,"
            echo "    \"sha1\": \"$theSha\""
            echo "  }"
        fi

    else 
    
        echo "File \"$file\" does not exist."	
        doHelp
                
    fi

done
