<#

    .SYNOPSIS
    This PowerShell script is "get-prefetch.ps1". It provides filename, size, and sha1.

    .DESCRIPTION
    The script accepts a \path\to\file as input parameter. Wildcards are permitted. The script returns the file(s) filename, size, and sha1 hash. These are useful when building BigFix prefetch blocks.

    .PARAMETER Path
    Enter \path\to\file on the command line.

    .PARAMETER Params
    Output the BigFix parameter block.

    .PARAMETER Json
    Output a JSON blob.

    .PARAMETER All
    Output all formats.

    .EXAMPLE 
    
    PS> get-prefetch.ps1 \path\to\file
    *** file ***
      theName = file
      theSize = 123
      theSha  = [sha1 hash]

    .EXAMPLE

    PS> get-prefetch.ps1 \path\to\file -Json
    *** file ***
      ** JSON **
      {
        "filename": "file",
        "size": 123,
        "sha1": "[sha1 hash]"
      }

    .LINK
    https://github.com/atlauren/bigfix/get-prefetch.ps1

    .NOTES
    atlauren@uci.edu
    2022-11-21 First publish
    2025-04-28 add parameter-formatted output
    2026-08-27 separate output sections by switch; add -All

#>

Param (

    [parameter(Mandatory=$true,
        ParameterSetName="FileSet",
        Position=0,
        HelpMessage="Enter the \path\to\file.")]
    [ValidateScript(
        { Test-Path $_ -PathType 'Leaf' }
        )]
    [string[]]$Path,

    [switch]$Params,
    [switch]$Json,
    [switch]$All

)

# determine output mode; default is basic
$outputMode = "basic"
if ($Params) { $outputMode = "params" }
if ($Json)   { $outputMode = "json" }
if ($All)    { $outputMode = "all" }

$theFiles = (Get-ChildItem $Path)

foreach ($file in $theFiles) {

    $theName = $file.Name
    $theSize = $file.Length
    $theHash = (Get-FileHash -Algorithm SHA1 -Path $file)
    $theSha = $theHash.Hash

    if ($outputMode -eq "basic" -or $outputMode -eq "all") {
        echo "*** $theName ***"
        echo "  theName = $theName"
        echo "  theSize = $theSize"
        echo "  theSha  = $theSha"
    }

    if ($outputMode -eq "params" -or $outputMode -eq "all") {
        echo "*** $theName ***"
        echo "  ** PARAMETERS **"
        echo "`tparameter `"theFile`" = `"$theName`""
        echo "`tparameter `"theSha1`" = `"$theSha`""
        echo "`tparameter `"theSize`" = `"$theSize`""
    }

    if ($outputMode -eq "json" -or $outputMode -eq "all") {
        echo "*** $theName ***"
        echo "  ** JSON **"
        echo "  {"
        echo "    `"filename`": `"$theName`","
        echo "    `"size`": $theSize,"
        echo "    `"sha1`": `"$theSha`""
        echo "  }"
    }

}
