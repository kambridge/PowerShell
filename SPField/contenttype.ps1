#Get Content Type
#Description: Get lists using a specific content type

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

$site = Get-SPSite "<url>"

foreach ($web in $site.AllWebs){
    $column = $web.Fields["<field name>"]
    $lists = $column.ListsFieldUsedIn()     

    $lists | ForEach-Object {
        $listurl = $site.AllWebs[$_.WebID]
        $listname = $web.Lists[$_.ListID]
        
        write-host $listurl.Title  $listname.Title  $listname.Url 
    }

}
$web.Dispose()
$site.Dispose()
