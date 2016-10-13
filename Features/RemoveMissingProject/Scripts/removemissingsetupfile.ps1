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

#Get content from XML Path
#Data from Get-MissingSetupFile()
#Generated from .\RemoveMissingProject\XSD\missingsetupfiles.xsd
Param([string] $XMLFilePath = ".\RemoveMissingProject\XML\missingsetupfiles.xml"

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
    | Out-File -append ".\Output\missingsetupfiles.txt"

}
<#
function Get-MissingSetupFiles () {
  Write-Host("Getting content from " + $XMLFilePath)
  [xml] $config = Get-Content $XMLFilePath

  #loop through each missing feature append info to file
  $config.MissingFilesTable.MissingFilesRow | Foreach-object{

  #Write-host $_.ContentDatabase $_.Feature
  Get-MissingSetupFile -SqlServer "<sql instance>" -SqlDatabase "$($_.ContentDatabase)" -FilePath "$($_.Feature)"
  }
#>

<#     Get URL of Offending File    #>
Write-Host("Getting content from " + $XMLFilePath)
[xml] $config = Get-Content $XMLFilePath

#Loop through each missing feature and get web url
$config.FilesTable.FileRow | Foreach-Object{
  $site = Get-SPSite -Limit all | where {$_.Id -eq "$($_.SiteID)"
  $web = $site | Get-SPWeb -Limit all | where {$_.Id -eq "$($_.WebID)"
  $web.url
  $file = $web.GetFile([Guid]"$($_.ID)")
  $file.ServerRelativeUrl
  <# DELETE FILE #>
  $file.ServerRelativeUrl
    try{
      #$file.delete()
    }catch{
      write-host -ForegroundColor red "There has been an error trying to remove the file:" $file
    }
}


  
  
