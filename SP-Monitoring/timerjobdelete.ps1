#Check to see if the SharePoint snapin is loaded.  If not, load it.
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
   Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
   "NOTE: this utility should be run from the Sharepoint Management Console"
}

$timers = Get-SPTimerJob | where {$_.name -like "<name of timer job>"} | Select DisplayName, ID, WebApplication

Write-Host $timers

foreach ($timer in $timers){
    $job = Get-SPTimerJob -ID $timer.ID
    Write-Host $job.DisplayName $job.Name $job.ID
    #$job.Delete()
}
