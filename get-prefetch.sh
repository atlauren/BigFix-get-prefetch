#!/bin/bash
# 
# get-prefetch.sh
# Bash script to compute filename, size, and sha1.
# Useful when building BigFix prefetch blocks.
# 
# atlauren@uci.edu
# 2011-11-21 First publish
#
# https://github.com/atlauren/bigfix/get-prefetch.sh
# 

doHelp () {
	echo "get-help.sh /path/to/file*"
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

		echo "*** $theName ***"
		echo "  theName = $theName"
		echo "  theSize = $theSize"
		echo "  theSha  = $theSha"

	else 
	
		echo "File \"$file\" does not exist."	
		doHelp
				
	fi

done
