<#DESCRIPTION: 
Get-WebAppPoolState-Gets the run-tie state of an IIS application pool
Get-WebAppPoolState [[-Name] <string>]
technet.microsoft.com/en-us/library/hh867896.aspx
#>

<#DEPLOYMENT INSTRUCTIONS: 
Open a SharePoint Management Shell as an Administrator. Go to the the directory the script lives in. Start by using ".\": for example .\iispools.ps1 -FilePath ".\Output" ACCESS ERRORS: Refer to the following link: http://support.microsoft.com/kb/896148/en-us
#>

#Create FilePath 
param([string] $FilePath = ".\Output\_" + $($ServerName) + "_.txt"

#Import WebAdministration
if((Get-Module WebAdministration -ErrorAction SilentlyContinue) -eq $null){
   Import-Module WebAdministration
}

$ServerNames = "<servername>","<servername>","I<servername>","<servername>"

foreach($ServerName in $ServerNames){
    $TitleOG = $ServerName + " | State Values: 1-starting; 2-started; 3-stopping; 4-stopped"
    
    <#
      Get-WmiObject -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy -Impersonation Impersonate -Class IIsApplicationPoolSetting -ComputerName $ServerName |  select PATH, AppPoolState |  Out-GridView -Title $TitleOG
      Invoke-Command -ComputerName $ServerName {Import-Module WebAdministration;Set-Location IIS:\AppPools; dir | Out-File $FilePath}
    #>
    Get-WmiObject -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy -Impersonation Impersonate -Class IIsApplicationPoolSetting -ComputerName $ServerName |  select PATH, Name, AppPoolState | Out-File -append $FilePath 

}

