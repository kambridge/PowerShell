<##### READ DESCRIPTIONS BELOW #####>

# Get content from XML Path
 Param([string] $filePath = "D:\ULS\PROD_missingfeaturefiles_08.04.2015.xml")

#Current Date
$date = Get-Date -UFormat "%m_%d_%Y"
Write-Host "Current date" $date

<#
<#
.SYNOPSIS

.DESCRIPTION
    
.AUTHOR
    Phil Childs
    June 12, 2011
    
.LINK
    http://get-spscripts.com/2011/08/diagnose-missingwebpart-and.html
#>


<#
    DO NOT CALL THIS FUNCTION DIRECTLY
#>
function Run-SQLQuery ($SqlServer, $SqlDatabase, $SqlQuery) {
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = "Server=" + $SqlServer + ";Database=" + $SqlDatabase + ";Integrated Security=true"
    
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.CommandText = $SqlQuery
    $sqlCmd.Connection = $sqlConnection
    
    $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $sqlAdapter.SelectCommand = $sqlCmd
    
    $dataSet = New-Object System.Data.DataSet
    
    $sqlAdapter.Fill($dataSet)
    $sqlConnection.Close()
    
    $dataSet.Tables[0]
}


<#
.SYNOPSIS
    
.DESCRIPTION
    
    Once you have identified the file and its location, you must determine how
    best to resolve the issue.
    
    A sample Health Analyzer finding from which the inputs are required:
        
        [MissingWebPart] WebPart class [c4dc6e23-03f1-643b-2b6a-27af4a38cd5e]
        is referenced [1] times in the database [sp2010_content_oesims2], but
        is not installed on the current farm. Please install any
        feature/solution which contains this web part. One or more web parts
        are referenced in the database [sp2010_content_oesims2], but are not
        installed on the current farm. Please install any feature or solution
        which contains these web parts.
        
    From the output the source or cause of the MissingWebPart warning can be
    deduced from DirName and LeafName:
        apps/oesims/FoldersDetail.aspx
    
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
    ID              : f5fc66e7-920a-4b44-9e3d-3a5ab825093f
    SiteID          : 7b4d043c-8bbe-4068-ad91-3c270dfae151
    DirName         : apps/oesims
    LeafName        : FoldersDetail.aspx
    WebID           : 1876be06-419f-46fb-a942-a15e510f1a70
    ListID          : 
    tp_ZoneID       : g_F4A1614EB8194173B3ABF3936D0FEF9B
    tp_DisplayName  :
#>
function Get-MissingWebPart ($SqlServer, $SqlDatabase, $ClassID) {
    if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null) {
        Add-PSSnapin Microsoft.SharePoint.PowerShell
    }
    
    Run-SQLQuery `
        -SqlServer $SqlServer `
        -SqlDatabase $SqlDatabase `
        -SqlQuery "SELECT * FROM AllDocs INNER JOIN AllWebParts ON AllDocs.Id=AllWebParts.tp_PageUrlID WHERE AllWebParts.tp_WebPartTypeID='$ClassID'" `
        | select ID, SiteID, DirName, LeafName, WebID, ListID, tp_ZoneID, tp_DisplayName `
        | Format-Table -Wrap | Out-File -append "$(D:\ULS\MissingWebparts_" + $date + ".txt)"
        
}

function Get-MissingWebPartURL ($SiteID, $DirName, $LeafName) {
    $spSite = Get-SPSite $SiteID
    #Write-Host "$($spSite.Url)/$($DirName)/$($LeafName)?contents=1" | Out-File -append D:\ULS\MissingWebpartInfo_08.04.15.txt
    $wpurl = "$($spSite.Url)/$($DirName)/$($LeafName)?contents=1"
    $wpurl | Out-File -append "$(D:\ULS\MissingWebpartInfo_" + $date + ".txt)"
    Write-Host $wpurl
}

<#
.SYNOPSIS
    
.DESCRIPTION
    Missing assembly warnings typically occur when an EventReceiver remains
    registered to a list or library but the underlying solution was removed
    from the farm.
    
    Once you have identified the EventReceiver, you must determine how best to
    resolve the issue. In some cases you may be able to remove the EventReceiver
    from the list or library. In other cases, you may need to delete the list
    or library.
    
    You should pipe the output of this function to a text file to facilitate
    your remedial action.
    
    A sample Health Analyzer finding from which the inputs are required:
    
        [MissingAssembly] Assembly [KnowledgeBaseEventHandler, Version=14.0.0.0,
        Culture=neutral, PublicKeyToken=71e9bce111e9429c] is referenced in the
        database [SP2010_Content_SPApps_BMD], but is not installed on the
        current farm. Please install any feature/solution which contains this
        assembly. One or more assemblies are referenced in the database
        [SP2010_Content_SPApps_BMD], but are not installed on the current farm.
        Please install any feature or solution which contains these assemblies.
    
    The output returns several pieces of information:
    • The HostID is the GUID of the object containing the Event Receiver.
    • The HostType is the object type of the host. Use
      http://msdn.microsoft.com/en-us/library/ee394866(v=prot.13).aspx to
      determine the type.
    
    The EventReceiver may appear 
    If the HostType is a List or Library you can use the Remove-MissingAssembly
    function to attempt to delete the EventReceiver pointer. Or you could
    simply choose to delete the List or Library.

.PARAMETER SqlServer
    The SQL Server computer name that hosts the specified database. Can be a
    SQL Alias if aliases are configured on the local computer.
    
.PARAMETER SqlDatabase
    The database found in the Health Analyzer finding. It is the value (minus
    the [] brackets) found immediately after the word "database".
    
.PARAMETER Assembly
    The Assembly is found in the Health Analyzer finding. It is the value
    (minus the [] brackets) found immediately after the word "Assembly".
    
.USAGE
    
.OUTPUT
  
#>
function Get-MissingAssembly ($SqlServer, $SqlDatabase, $Assembly) {
    if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null) {
        Add-PSSnapin Microsoft.SharePoint.PowerShell
    }
    
    Run-SQLQuery `
        -SqlServer $SqlServer `
        -SqlDatabase $SqlDatabase `
        -SqlQuery "SELECT * FROM EventReceivers WHERE Assembly='$Assembly'" `
        | select ID, Name, SiteID, WebID, HostID, HostType `
        | Format-List
}
<#
#>
function Remove-MissingAssembly ($SiteID, $WebID, $HostID, $EventReceiverID) {
    if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null) {
        Add-PSSnapin Microsoft.SharePoint.PowerShell
    }
    
    $site = Get-SPSite $SiteID
    Write-Host $site.Url
    $web = $site | Get-SPWeb $WebID
    Write-Host $web.Url
    $list = $web.Lists | where {$_.Id -eq $HostID}
    if ($list -ne $null) {
        $evtRcvr = $list.EventReceivers | where {$_.Id -eq $EventReceiverID}
        if ($evtRcvr -ne $null) {
            $evtRcvr.Delete()
            Write-Host "evtRcvr deleted"
        }
        else {
            Write-Host "evtRcvr = null"
        }
    }
    else {
        Write-Host "list = null"
    }
    Write-Host "`n"
}

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
    
        [MissingSetupFile] File [Features\CustomBranding\ICE.master] is
        referenced [1] times in the database [sp2010_content_oesims2], but is
        not installed on the current farm. Please install any feature/solution
        which contains this file. One or more setup files are referenced in the
        database [sp2010_content_oesims2], but are not installed on the current
        farm. Please install any feature or solution which contains these files.
        
    From the output the source or cause of the MissingSetupFile warning can be
    deduced from DirName and LeafName:
        apps/oesims/_catalogs/masterpage/ICE.master

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
    ID          : f5fc66e7-920a-4b44-9e3d-3a5ab825093f
    SiteID      : 7b4d043c-8bbe-4068-ad91-3c270dfae151
    DirName     : apps/oesims/_catalogs/masterpage
    LeafName    : ICE.master
    WebID       : 1876be06-419f-46fb-a942-a15e510f1a70
    ListID      : a04dda01-a52d-4d5b-b3b4-fcd70a05e4ba
#>
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
        | Out-File -append D:\ULS\MissingFeaturesInfo_08.04.15.txt
      
}
function Get-MissingSetupFiles () {
    Write-Host("Getting content from " + $filePath)
    [xml] $config = Get-Content $filePath
    #loop through each missing feature append info to file
    $config.MissingFilesTable.MissingFilesRow | Foreach-object{
       #Write-host $_.ContentDatabase $_.Feature
        Get-MissingSetupFile -SqlServer "<sql instance>" -SqlDatabase "$($_.ContentDatabase)" -FilePath "$($_.Feature)"
    }
}

<#
#Delete File

$site = Get-SPSite -Limit all | where { $_.Id -eq "<id>"}
$web = $site | Get-SPWeb -Limit all | where { $_.Id -eq "<id>"}
$web.Url

$file = $web.GetFile([Guid]"<guid>")
$file.ServerRelativeUrl
try{
   #$file.delete()
}catch{
    write-host -ForegroundColor red "There has been an error trying to remove the file:" $file
}
#>

#Get-MissingSetupFiles

Get-MissingWebPart -SqlServer "<sql instance>" -SqlDatabase "<database name>" -ClassID "<ID>" 
#Get-MissingWebPart -SqlServer "<sql instance>" -SqlDatabase "<database name>" -ClassID "<ID>" | Out-File -FilePath D:\MissingWebPart_08.04.15.txt -Append:$true

#Get-MissingAssembly -SqlServer $SqlServer -SqlDatabase $SqlDatabase -Assembly $Assembly
