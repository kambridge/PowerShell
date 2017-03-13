w#IIS RESET FOR ALL SP FARM SERVERS
#DESCRIPTION:
#NOTE:

cls

Write-Host "Loading SharePoint Commandlets" 
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
Write-Host -Foregroundcolor green "Commandlets loaded...Loading variables"

Write-Host
[array]$servers = Get-SPServer | ? {$_.Role -eq "Application"}
$farm = Get-SPFarm

foreach ($server in $servers){
  Write-Host -ForegroundColor yellow "Attempting to reset IIS for $server"
  iisreset $server /noforce "\\"$_.Address
  iisreset $server /Status "\\"$_.Address
  Write-Host
  Write-Host -Foregroundcolor green "IIS has been reset for $server"
}

Write-Host -Foregroundcolor green "IIS has been reset across SharePoint farm"
Start-Sleep -Seconds 5
