#DELETE ITEMS FROM LISTS
#DESCRIPTION:
#NOTES:

[string] $webs = ".\XML\webs.xml"
[xml] $config = Get-Content $webs

#[System.reflection.Assembly]::LoadwithPartialName("Microsoft.SharePoint")
#Add-PSSnapin "Microsoft.SharePoint.Powershell"

function DeleteItemsFromList($web, $listName, $camlQuery, $rowLimit)
{
    $spList = $web.Lists[$listName]
    #Write-Host $spList
    if($spList -eq $null)
    {
        return;
    }
    $spQuery = new-object Microsoft.SharePoint.SPQuery  
    $spQuery.Query = $camlQuery 
    $spQuery.RowLimit = $rowLimit
    $spListItemCollection = $spList.GetItems($spQuery)     

    # Create batch remove CAML query   
    $batchRemove = '<?xml version="1.0" encoding="UTF-8"?><Batch>';     
    # The command is used for each list item retrieved   
    $command = '<Method><SetList Scope="Request">' +   
    $spList.ID +'</SetList><SetVar Name="ID">{0}</SetVar>' +   
                '<SetVar Name="Cmd">Delete</SetVar></Method>';     
    $count = $spListItemCollection.Count
    foreach ($item in $spListItemCollection){
        $batchRemove += $command -f $item.Id;   
    }   
    $batchRemove += "</Batch>";     

    # Remove the list items using the batch command   

    $spList.ParentWeb.ProcessBatchData($batchRemove) | Out-Null 
    
    return $count;
}

function StartDeletion($url, $listname, $caml, $action, $rowLimit){
    $site = new-object Microsoft.SharePoint.SPSite $url
    #Write-Host $site
    <#
    $listName = $args[1]
    Write-Host $listName
    $caml = $args[2]
    $action = $args[3]
    $rowLimit = 0 + $args[4]
    #>

    #Get-SpWeb
    #$webs = $site.AllWebs

    $oldCount = 0
    $count = 1
    $total = 0
    $formatteddate = "{0:h:mm:ss tt zzz}" -f (get-date)
    Write-Host "Starting $formattedDate"
    while($true){
        $count = 0;
        $oldCount = 0;
        $config.SiteCollection.Site | Foreach-Object {
            $site.openweb()
            #Write-Host $site
            #foreach($web in $webs){
            $web = Get-SPWeb "$($_.Site)"
            #Write-Host $web
            $webName = $web.Title
            #Write-Host $listName
            $count = DeleteItemsFromList $web $listName $caml $rowLimit
            if($count -gt $oldCount){
                $oldCount = $count
            }
            $total = $total + $count
            
            #}
            $web.Dispose()
            if($oldCount -eq 0){
                break;
            }
        }
    }
    $formatteddate = "{0:h:mm:ss tt zzz}" -f (get-date)

    Write-Host "Ended at $formatteddate"
    Write-Host "Total Items Removed: $total"
    $site.Dispose()
}

StartDeletion -url "<url>" -listname "<listname>" -caml "<Query></Query>" -action "NotUsed" -rowlimit 5000
