#CHECK SECURITY UPDATES ON SERVERS IN FARM
#DESCRIPTION:
#NOTES:

function CheckUpdates(){
  $Servers = "<severname>", "<severname>", "<severname>"
  foreach ($Server in $Servers){
      $filepath = "D:\" + $Server + "_securityupdate.csv"
      Get-WmiObject -Authentication PacketPrivacy -Impersonation Impersonate -Class "win32_quickfixengineering" ` 
      -ComputerName $Server | Select-Object -Property @{Name="Server"; Expression={$_.CSName}}, "Description", "FixComments", "HotfixID", 
      @{Name="InstallDate"; Expression={([DateTime]($_.InstallDate)).ToLocalTime()}},
      "InstalledBy", @{Name="InstalledOn"; Expression={([DateTime]($_.InstalledOn)).ToLocalTime()}}, "Name","ServicePackInEffect", "Status" | Export-Csv -Delimiter "," -Path $filepath -notype
  }
}

CheckUpdates
