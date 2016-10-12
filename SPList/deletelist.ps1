# DELETE SHAREPOINT LIST
Param([string] $listname = $("Please specify a list"), [string] $weburl = $("Please specify a list"))

#Check to see if the SharePoint snapin is loaded.  If not, load it.
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
   Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
   "NOTE: this utility should be run from the Sharepoint Management Console"
}
 
function DeleteList {
    $weburl = Read-Host "Web URL:" 
    $listname = Read-Host "List Name:" 
    $web = Get-SPWeb $weburl -ErrorAction SilentlyContinue 
    Write-Host $web -foregroundcolor "yellow"
    $list = $web.lists[$listname]
    Write-Host $list -foregroundcolor "yellow"
    $confirmation = Read-Host "Are you sure you want to delete? (y or n)"
     
    if ($confirmation -eq "y"){
       Write-Host "Deleting:" $list "-" $list.ID -foregroundcolor "green"
       $list.Delete()
    }
    else {
       Write-Host "Item not deleted" -foregroundcolor "red"
    }
     
    #Housekeeping 
    $web.dispose() 
}
DeleteList -weburl -listname
