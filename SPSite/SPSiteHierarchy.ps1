#SITE HIERARCHY
#DESCRIPTION:
#NOTES: 

function Start-SPSiteHierarchy(){
  #Current Date
  $date = Get-Date -UFormat "%m_%d_%Y"
  
  #Get Web Application
  $webapps = Get-SPWebApplication
  foreach ($webapp in $webapps){
    Write-Host "Site Hierarchy of "$($webapp)" starting..."
    $getwebapp = Get-SPWebApplication $webapp
    $filepath = ".\OutPut\" + $getwebapp.Name + $date + ".csv"
    $logs = $getwebapp | Get-SPSite -Limit All | Get-SPWeb -Limit All | Select Title, URL, ID, ParentWebID, Created | Export-CSV $filepath
    
    foreach ($log in $logs){
      Write-Progress -Activity "Starting inventory of $($webapp)" -PercentComplete (100) -Status "In Progress..."; Start-Sleep 3;
    }
  }
}
Start-SPSiteHierarchy
