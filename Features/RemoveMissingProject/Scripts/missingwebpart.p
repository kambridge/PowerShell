<#
.SYNOPSIS
    
.DESCRIPTION
    
    Once you have identified the file and its location, you must determine how
    best to resolve the issue.
    
    A sample Health Analyzer finding from which the inputs are required:
        
        [MissingWebPart] WebPart class [<id>]
        is referenced [1] times in the database [<contentdatabase>], but
        is not installed on the current farm. Please install any
        feature/solution which contains this web part. One or more web parts
        are referenced in the database [<contentdatabase>], but are not
        installed on the current farm. Please install any feature or solution
        which contains these web parts.
        
    From the output the source or cause of the MissingWebPart warning can be
    deduced from DirName and LeafName:
        <path>/FoldersDetail.aspx
    
    You can find the Zone by the value of tp_ZoneID.
    
    Once you have the URL to the Web Part from the page browse to the site with
    the query string "?contents=1" appended (minus the double-quotes). Select
    the offending Web Part and click Delete.

.PARAMETER SqlServer
    The SQL Server computer name that hosts the specified database. Can be a
    SQL Alias if aliases are configured on the local computer.
    
.PARAMETER SqlDatabase
    The database found in the Health Analyzer finding. It is the value (minus
    the [] brackets) found immediately after the word "database".
    
.PARAMETER ClassID
    The WebPart class ID found in the Health Analyzer finding. It is the value
    (minus the [] brackets) found immediately after the word "class".
    
.USAGE
    Get-MissingSetupFileID
        -SqlServer "<computername>"
        -SqlDatabase "<databasename>"
        -ClassID "<classid>"
    
.OUTPUT
    ID              : <guid>
    SiteID          : <siteid>
    DirName         : <dir>
    LeafName        : <leafname>
    WebID           : <webid>
    ListID          : 
    tp_ZoneID       : <zoneid>
    tp_DisplayName  :
#>

<# PARAMETERS #>
Param(
  [string] $removewebpartxml = ".\RemoveMissingProject\XML\missingwebpartinfo.xml",
  [string] $webpartHAinfo = ".\RemoveMissingProject\XML\webpartHAinfo.xml",
)

<# GET DATA FOR $webpartinfo FROM SP HEALTH ANALYZER #>

function Get-MissingWebPart ($SqlServer, $SqlDatabase, $ClassID) {
    if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null) {
        Add-PSSnapin Microsoft.SharePoint.PowerShell
    }
    Write-Host("Getting content from " + $webpartHAinfo)
    [xml] $config = Get-Content $webpartHAinfo
    #loop through each missing webpart 
    $filepath = ".\RemoveMissingProject\Output\missingwebpartinfo_" + $date + ".txt"
    $config.WebPartTable.WebpartRow | Foreach-object{
        #Write-Host $_.SqlServer
        #Write-Host $_.SqlDatabase
        Run-SQLQuery `
            -SqlServer "$($_.SqlServer)" `
            -SqlDatabase "$($_.SqlDatabase)" `
            -SqlQuery "SELECT * FROM AllDocs INNER JOIN AllWebParts ON AllDocs.Id=AllWebParts.tp_PageUrlID WHERE AllWebParts.tp_WebPartTypeID= '$($_.ClassID)'" `
            | select ID, SiteID, DirName, LeafName, WebID, ListID, tp_ZoneID, tp_DisplayName `
            | Format-Table -Wrap -Autosize `
            | Out-String -Width 4096 `
            | Out-File -append $filepath
    }        
}

function Get-MissingWebPartURL ($SiteID, $DirName, $LeafName) {
    $filepath = ".\RemoveMissingProject\Output\LogMissingWebpartURLs_" + $date + ".txt"
    Write-Host("Getting content from " + $removewebpartxml)
    [xml] $config = Get-Content $removewebpartxml
    #loop through each missing webpart   
    $config.WebPartTable.WebpartRow | Foreach-object{
        $siteid = $_.SiteID
        $spSite = Get-SPSite $siteid
        $webid = $_.WebID
        $web = $spSite | Get-SPWeb -Limit all | where { $_.Id -eq "$($webid)" }
        #Write-Host "$($spSite.Url)/$($DirName)/$($LeafName)?contents=1" | Out-File -append $infofilepath
        $wpurl = "$($spSite.Url)/$($_.DirName)/$($_.LeafName)?contents=1"
        $wpurl | Out-String -Width 4096 `
        | Out-File -append $filepath
        Write-Host $wpurl
    }
}

<# GET MISSING WEB PART INFO #>
#Get-MissingWebPart

<# GET MISSING WEBPART URL #>
#Get-MissingWebPartURL

