<#

    .SYNOPSIS
    This PowerShell script is "get-prefetch.ps1". It provides filename, size, and sha1.

    .DESCRIPTION
    The script accepts a \path\to\file as input parameter. Wildcards are permitted. The script returns the file(s) filename, size, and sha1 hash. These are useful when building BigFix prefetch blocks.

    .PARAMETER Path
    Enter \path\to\file on the command line.

    .PARAMETER Basic
    Output basic info (default).

    .PARAMETER Params
    Output the BigFix parameter block.

    .PARAMETER Json
    Output a JSON blob.

    .PARAMETER All
    Output all sections.

    .PARAMETER Clip
    Also copy the content blocks (without the ** headers **) to the clipboard.

    .EXAMPLE 
    
    PS> get-prefetch.ps1 \path\to\file
    *** file ***
      ** BASIC **
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
    2026-08-27 separate output sections by switch; theName always output
    2026-09-02 add -Clip to copy header-free content to the clipboard

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

    [switch]$Basic,
    [switch]$Params,
    [switch]$Json,
    [switch]$All,
    [switch]$Clip

)

# determine output mode; basic is default
$outputMode = "basic"
if ($Basic)  { $outputMode = "basic" }
if ($Params) { $outputMode = "params" }
if ($Json)   { $outputMode = "json" }
if ($All)    { $outputMode = "all" }

$clipLines = @()

# header line: never copied to the clipboard
function hdr ($text) {
    Write-Output $text
}

# content line: copied to the clipboard when -Clip is set
function out ($text) {
    Write-Output $text
    if ($Clip) { $script:clipLines += $text }
}

$theFiles = (Get-ChildItem $Path)

foreach ($file in $theFiles) {

    $theName = $file.Name
    $theSize = $file.Length
    $theHash = (Get-FileHash -Algorithm SHA1 -Path $file)
    $theSha = $theHash.Hash

    # theName is always output
    hdr "*** $theName ***"

    if ($outputMode -eq "basic" -or $outputMode -eq "all") {
        hdr "  ** BASIC **"
        out "  theName = $theName"
        out "  theSize = $theSize"
        out "  theSha  = $theSha"
    }

    if ($outputMode -eq "params" -or $outputMode -eq "all") {
        hdr "  ** PARAMETERS **"
        out "`tparameter `"theFile`" = `"$theName`""
        out "`tparameter `"theSha1`" = `"$theSha`""
        out "`tparameter `"theSize`" = `"$theSize`""
        out "`tparameter `"theFolder`" = `"{preceding text of last `".`" of following text of first `"_`" of (parameter `"theFile`")}`""
    }

    if ($outputMode -eq "json" -or $outputMode -eq "all") {
        hdr "  ** JSON **"
        out "  {"
        out "    `"filename`": `"$theName`","
        out "    `"size`": $theSize,"
        out "    `"sha1`": `"$theSha`""
        out "  }"
    }

}

if ($Clip) {
    $clipLines -join [Environment]::NewLine | Set-Clipboard
}
