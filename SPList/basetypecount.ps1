#LIST NAME AND COUNT BASED ON BASE TYPE
#DESCRIPTION: Gathers the Names of all of the Document Libraries in SharePoint along with the item count
#NOTES:

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

$results = @()
$webApps = Get-SPWebApplication <webappurl>

#Start Actual Script for Counting
Start-SPAssignment -Global
$date = Get-Date -UFormat "%m_%d_%Y"

$OutputFile =".\Output\"+$webApps.Name+$date+"_DocumentInventory.csv"

foreach($webApp in $webApps)
{
    foreach($siteColl in $webApp.Sites)
    {
        foreach($web in $siteColl.AllWebs)
        {
            $webUrl = $web.Url
            $docLibs =  $web.Lists | Where-Object {$_.BaseType -eq "DocumentLibrary"}
            $docLibs | Add-Member -MemberType ScriptProperty -Name WebUrl -Value {$webUrl}
            $results += ($docLibs | Select-Object -Property WebUrl, Title, ItemCount)
            #$count = ($docLibs | Select-Object -Property ItemCount)     
        } #endforeach web in SiteColl.AllWebs
    } #endforeach SiteColl in WebApp.Sites
} #end foreach webapp in webapps

#populate CSV
$results | Export-Csv -Path $OutputFile -NoTypeInformation

#CSV path/Filename
#$contents = Import-csv "$OutputFile"

