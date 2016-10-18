#Check SHAREPOINT SERVICES
#DESCRIPTION: 
#NOTES: https://msdn.microsoft.com/en-us/library/aa394418(v=vs.85).aspx

param([switch]$AutoSize)

if((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null){
  Write-Host "Loading Microsoft.SharePoint.PowerShell module..."
  Add-PSSnapin Microsoft.SharePoint.PowerShell
}

#SharePoint Services
$services = @("spadminv4", "sptimerv4", "sptracev4", "spsearchv4", "osearch14", "c2wts", "fimservice", "fimsynchronizationservice")

#SharePoint Farm Servers
$servers = @(Get-SPServer | where {$_.Role -eq "Application"} | ForEach-Object {$_.Name})

#Array for results
$arr = @()

foreach ($service in $services){
  foreach ($server in $servers){
    cls; Write-Host "processing: $service`t$server"
    $wmiObj = Get-WMIObject -ComputerName $server -Class win32_service | where {$_.Name -eq $service}
    
    $psObj = New-Object PSObject
    $psObj | Add Member NoteProperty Service $wmiObj.DisplayName
    $psObj | Add Member NoteProperty Host $wmiObj.SystemName
    $psObj | Add Member NoteProperty Identity $wmiObj.StartName
    $psObj | Add Member NoteProperty State $wmiObj.State
    $psObj | Add Member NoteProperty Status $wmiObj.Status
    
    #add to output array
    $arr += $psObj
  }  
}

#Write array to display by group
cls; Write-Output $arr | Format-Table -Property Host, Identity, State, Status, -GroupBy Service -AutoSize:$AutoSize

