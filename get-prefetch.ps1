 <#

    .SYNOPSIS
    This PowerShell script is "get-prefetch.ps1". It provides filename, size, and sha1.

    .DESCRIPTION
    The script accepts a \path\to\file as input parameter. Wildcards are permitted. The script returns the file(s) filename, size, and sha1 hash. These are useful when building BigFix prefetch blocks.

    .PARAMETER Path
    Enter \path\to\file on the command line.

    .EXAMPLE 
    
    PS> get-prefetch.ps1 \path\to\file
    *** \path\to\file ***
      TheName: file
      TheSize: 123
      TheSha : [sha1 hash]

    .EXAMPLE

    PS> get-prefetch.ps1 \path\to\files
    *** \path\to\file1 ***
      TheName: file1
      TheSize: 123
      TheSha : [sha1 hash1]
    *** \path\to\file2 ***
      TheName: file2
      TheSize: 456
      TheSha : [sha1 hash2]

	.LINK
	https://github.com/atlauren/bigfix/get-prefetch.ps1

    .NOTES
    atlauren@uci.edu
    2022-11-21 First publish

#>

Param (

	[parameter(Mandatory=$true,
		ParameterSetName="FileSet",
		Position=0,
		HelpMessage="Enter the \path\to\file.")]
	[ValidateScript(
		{ Test-Path $_ -PathType 'Leaf' -IsValid }
        )]
	[string[]]$Path

)

$theFiles = (Get-ChildItem $Path)

foreach ($file in $theFiles) {

$theName = $file.Name
$theSize = $file.Length
$theHash = (Get-FileHash -Algorithm SHA1 -Path $file)
$theSha = $theHash.Hash

echo "*** $theName ***"
echo "  theName = $theName"
echo "  theSize = $theSize"
echo "  theSha  = $theSha"

} 
