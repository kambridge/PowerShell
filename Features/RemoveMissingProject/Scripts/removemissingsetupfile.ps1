<#
.SYNOPSIS
    Returns identifying information for the file causing the MissingSetupFile
    warning.
    
.DESCRIPTION
    This script DOES NOT identify a missing setup file. This script only
    identifies the file and the file's location that is causing the Health
    Analyzer MissingSetupFile warning.
    
    Once you have identified the file and its location, you must determine how
    best to resolve the issue.
    
    A sample Health Analyzer finding from which the inputs are required:
    
        [MissingSetupFile] File [Features\CustomBranding\Custom.master] is
        referenced [1] times in the database [<databasename>], but is
        not installed on the current farm. Please install any feature/solution
        which contains this file. One or more setup files are referenced in the
        database [<databasename>], but are not installed on the current
        farm. Please install any feature or solution which contains these files.
        
    From the output the source or cause of the MissingSetupFile warning can be
    deduced from DirName and LeafName:
        <managedpath>/<site>/_catalogs/masterpage/Custom.master

.PARAMETER SqlServer
    The SQL Server computer name that hosts the specified database. Can be a
    SQL Alias if aliases are configured on the local computer.
    
.PARAMETER SqlDatabase
    The database found in the Health Analyzer finding. It is the value (minus
    the [] brackets) found immediately after the word "database".
    
.PARAMETER FilePath
    The relative path found in the Health Analyzer finding. It is the value
    (minus the [] brackets) found immediately after the word "File".
    
.USAGE
    Get-MissingSetupFileID
        -SqlServer "<computername>"
        -SqlDatabase "<databasename>"
        -FilePath "<relativepath>"
    
.OUTPUT
    ID          : <id>
    SiteID      : <siteid>
    DirName     : <managedpath>/<site>/_catalogs/masterpage/
    LeafName    : Custom.master
    WebID       : <webid>
    ListID      : <listid>
#>

<#    PARAMETERS    #>

<# Get content from XML Path #>
#Data from SP Health Analyzer Error Message
#Generated from .\RemoveMissingProject\XSD\HAmissingsetupfiles.xsd
Param([string] $XMLHAFilePath = ".\RemoveMissingProject\XML\HAmissingsetupfiles.xml"
Param([string] $XMLFilePath = ".\RemoveMissingProject\XML\missingsetupfiles.xml"

<# CALL SQL QUERY FUNCTION #>
. .\RemoveMissingProject\Scripts\runsqlquery.ps1

<# Runs on each feature #>
function Get-MissingSetupFile ($SqlServer, $SqlDatabase, $FilePath) {
  if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
  }

  Run-SQLQuery `
    -SqlServer $SqlServer `
    -SqlDatabase $SqlDatabase `
    -SqlQuery "SELECT * FROM AllDocs WHERE SetupPath = '$FilePath'" `
    | select ID, SiteID, WebID, DirName, LeafName, ListID `
    | Format-Table -Wrap -Autosize `
    | Out-String -Width 4096 `
    | Out-File -append ".\RemoveMissingProject\Output\missingsetupfiles.txt"

}

function Get-MissingSetupFiles () {
  Write-Host("Getting content from " + $XMLHAFilePath)
  [xml] $config = Get-Content $XMLHAFilePath

  #loop through each missing feature append info to file
  $config.HAMissingSetupFilesTable.HAMissingSetupFilesRow | Foreach-object{

  #Write-host $_.ContentDatabase $_.Feature
  Get-MissingSetupFile -SqlServer "<sql instance>" -SqlDatabase "$($_.ContentDatabase)" -FilePath "$($_.Feature)"
  }


<# Delete File #>
function Get-DeleteMissingSetupFiles (){
    Write-Host("Getting content from " + $XMLFilePath)
    [xml] $config = Get-Content $XMLFilePath
    #loop through each missing feature append info to file
    $filepath = ".\RemoveMissingProject\Output\deleletefiles_" + $date + ".txt"
    $config.FilesTable.FileRow | Foreach-object{
        $siteid = $_.SiteID
        $site = Get-SPSite -Limit all | where { $_.Id -eq "$($siteid)" }
        $webid = $_.WebID
        $web = $site | Get-SPWeb -Limit all | where { $_.Id -eq "$($webid)" }
        #$web.Url
        $guidid = $_.ID
        $listid = $_.ListID
        $listurl = $web.Lists | where { $_.Id -eq "$($listid)" }
        #Write-Host $listurl.DefaultDisplayFormUrl 
        $file = $web.GetFile([Guid]"$($guidid)")
        #$file.ServerRelativeUrl `s
        $fileurl = "$($web.url + "/" + $file.Url)|$($_.ID)|$($_.SiteID)|$($_.WebID)|$($_.DirName)|$($_.LeafName )|$($_.ListID)|$listurl.DefaultDisplayFormUrl" 
        #$fileurl = " $($web.url + "/" + $file.Url) | $listurl.DefaultDisplayFormUrl" 
        #$fileurl = "$($web.url + "/" + $file.Url) | $($_.LeafName) | $($_.DirName) | $listurl.DefaultDisplayFormUrl" 
        
        #Write-Host $fileurl
        $fileurl `
        | Format-Table `
        | Out-String -Width 4096 `
        | Out-File -append $filepath
               
        try{
           Write-Host $file
           #$file.delete()           
        }catch{
            write-host -ForegroundColor red "There has been an error trying to remove the file:" $file
        }
    }
}

  
  
