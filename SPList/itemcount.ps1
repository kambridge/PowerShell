#Get item count
#Description: Count all items in all lists in spweb

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") 
#Add-PSSnapin "Microsoft.SharePoint.Powershell"

$site = new-object Microsoft.SharePoint.SPSite $args[0]
$listName = $args[1]

$webs = $site.AllWebs

  foreach($web in $webs){

  #if($web.Lists[$listName] –ne $null)
  foreach($list in $web.Lists)

  {    
$listName = $list.Title                                           
                                              
$listCount = $list.ItemCount
                                                
# Write-Host "Web: $($web.Title) List: $listName \t $listCount"

$web.Title + "; " +  $listname + "; " + $listCount

}
}

