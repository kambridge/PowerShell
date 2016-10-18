#GET SIZE OF DATABASES IN FARM
#DESCRIPTION
#NOTE:

$database = Get-SPDatabase | Sort-Object disksizerequired -desc | Format-Table -autosize Name, WasCreated, @{Label ="Size in MB"; Expression = {$_.disksizerequired/1024/1024}}, @{Expression={$_.WebApplication};Label="WebApplication";width=100} | Out-File -append -filepath .\contentdatabases4.csv
Write-Host $database

<#
  #Get-SPDatabase | Sort-Object disksizerequired -desc | Format-Table Name, @{Label ="Size in MB"; Expression = {$_.disksizerequired/1024/1024}} | Out-File -append -filepath .\contentdatabases.txt

  Get-SPDatabase | Sort-Object disksizerequired -desc | Format-Table $data | Out-File -append -filepath .\contentdatabases.txt
  $data = @{Expression={$_.Name};Label="Name"},`
          @{Expression={$_.disksizerequired/1024/1024};Label="Size in MB"},`
          @{Expression={$_.WebApplication};Label="WebApplication"} 
#>
<#
  $databases = Get-SPDatabase
  foreach ($database in $databases){
      $info = ($_.Name + $_.disksizerequired/1024/1024)
      $info | Out-File -append -filepath .\contentdatabases.txt
  }
#>
