<# TEST/REPAIR SHAREPOINT CONTENT DATABASE
DESCRIPTION: Test and repair (or report needed repairs) content databases.
NOTES: Change the following: <database>, <url>, <id> and <instance>
#>

if ((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{Add-PSSnapin Microsoft.SharePoint.Powershell}

<#
#RUN ON ALL CONTENT DATABASES IN THE FARM

$CDBs = Get-SPContentDatabase
ForEach ($CDB in $CDBs)
{
    Write-Host "Detecting Orphans for " $CDB.Name
    $CDB.Repair($false)
}
#>

#Test-SPContentDatabase -name <database> -webapplication <url> -serverinstance <instance>
#$db = Get-SPContentDatabase -site "<url>"
#write-host $db.ID

#RUN ON A SPECIFIC CONTENT DATABASE IN THE FARM

$db = Get-SPDatabase -Identity "<id>" -ServerInstance "<instance>";
#note set this to $true if you want it to actually repair the database. $false will just list what it would repair

#never hurts
$db.Repair($false);
#$db.Repair($true);

$db.Update(); 
