#SPWeb Sizes
#Description: Get size of all webs in site collection.
#Notes: Change file path (out-file), web application url (Get-SPWebApplication) and site collection url (Get-SpSite).

$webapp = Get-SPWebApplication "<url>"

#Current Date
$date = Get-Date -UFormat "%m_%d_%Y"

$site = Get-SPSite "<url>"
foreach ($web in $site.AllWebs){
  $webSize = CalculateFolderSize($web.RootFolder)
  #Get Recycle Bin Size
    foreach($RecycleBinItem in $web.RecycleBin){
      $WebSize += $RecycleBinItem.Size
    }
    $Size = [Math]::Round($WebSize/1MB, 2)
    Write-Host  $web.Url ":`t" $Size "MB"
    #Dispose the object
    $web.dispose()
}
#Get Site Quota
function sitequota {
#Is Quota greater than 0
    if ($site.Quota.StorageMaximumLevel -gt 0) {
        $MaxStorage = $site.Quota.StorageMaximumLevel /1MB
    }else {
        $MaxStorage="0"
    }           
    #Quota greater than 0 
    if ($site.Usage.Storage -gt 0) {
        $StorageUsed = $Site.Usage.Storage /1MB
    }            
    #Quota greater than 0 and Max Storage greater than 0
    if ($StorageUsed -gt 0 -and $MaxStorage -gt 0){
        $SiteQuotaUsed = $StorageUsed/$MaxStorage* 100
    } 
    else{
        $SiteQuotaUsed = "0"
    }
    $Web = $site.Rootweb; 
    
    #Create Hash
    $hash = @{
        "Site Url" = $site.Url
        "Quota Limit (MB)" = $MaxStorage
        "Total Storage Used (MB)" = $StorageUsed
        "Site Quota Percentage Used" = $SiteQuotaUsed
    }
    $StorageUsedGB = $StorageUsed/1000
    if (($StorageUsed -gt 25000)-and ($StorageUsed -lt 75000)){
        Write-Host $site.Url, $StorageUsedGB "GB" -foregroundcolor "cyan"
    }
    elseif (($StorageUsed -gt 75000)-and ($StorageUsed -lt 100000)){
        Write-Host $site.Url, $StorageUsedGB "GB" -foregroundcolor "yellow"
    }
    elseif ($StorageUsed -gt 100000){
        Write-Host $site.Url, $StorageUsedGB "GB"-foregroundcolor "magenta"
    }
    #Convert the hash to an object and output to the pipeline
    New-Object PSObject -Property $hash
    $Site.Dispose()      
}
        Write-Host "Site Quota Function Ended"

<# Function to calculate folder size
function CalculateFolderSize($Folder){
    [long]$FolderSize = 0
      
    foreach ($File in $Folder.Files){
    #Get File Size
            $FolderSize += $file.TotalLength;
    
    #Get the Versions Size
        foreach ($FileVersion in $File.Versions){
            $FolderSize += $FileVersion.Size
        }
    }
    #Iterate through all subfolders
    foreach ($SubFolder in $Folder.SubFolders){
  #Call the function recursively
            $FolderSize += CalculateFolderSize $SubFolder
    }
        return $FolderSize
}#> 
