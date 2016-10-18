#GET SITE QUOTA
<#DESCRIPTION: The script get the web application and for each site collection it get the storage used, quota limit and site quota percentage.#>

#Configure the location for the output file & identify Web Application
Param([string]$FilePath=".\sitecolquota.csv", [string]$Siteurl = "");

Write-Host "Web Application:" $Webapp "File Path:" $Siteurl

#Create headers in outfile.
"Site URL"+","+"Quota Limit (MB)"+","+"Total Storage Used (MB)"+","+"Site Quota Percentage Used" | Out-File -Encoding Default -FilePath $FilePath;

#Create SharePoint Object
$Rootweb = New-Object Microsoft.Sharepoint.SPSite($Siteurl);

#Get Web Application of Site Collection
$Webapp = $Rootweb.WebApplication;

#Loops through each site collection within the Web app

Foreach ($Site in $Webapp.Sites){
    Write-Host "Getting Storage Information for:" $Site
    
    <#Write to Host
    $MaxStorageInfo = $MaxStorage = $Site.Quota.StorageMaximumLevel
    Write-Host $MaxStorageInfo#>
    
    #Is Quota greater than 0
    if ($Site.Quota.StorageMaximumLevel -gt 0) {
        $MaxStorage = $Site.Quota.StorageMaximumLevel /1MB
    }else {
        $MaxStorage="0"
    };
    
    <#Write to Host
    $StorageUsedinfo = $Site.Usage.Storage
    Write-Host $StorageUsedinfo#>
    
    #Quota greater than 0 
    if ($Site.Usage.Storage -gt 0) {
        $StorageUsed = $Site.Usage.Storage /1MB
    };
    
    <#Write to Host
    $SiteQuotaUsedInfo = $Storageusedinfo/$MaxStorage* 100
    Write-Host $SiteQuotaUsedInfo#>
    
    #Quota greater than 0 and Max Storage greater than 0
    if ($StorageUsed -gt 0 -and $MaxStorage -gt 0){
        $SiteQuotaUsed = $StorageUsed/$MaxStorage* 100
    } 
    else{
        $SiteQuotaUsed = "0"
    };
    
    #Create Table 
    $Web = $Site.Rootweb;
    $Site.Url + "," + $MaxStorage + "," + $StorageUsed + "," + $SiteQuotaUsed | Out-File -Encoding Default -Append -FilePath $FilePath; 
    $Site.Dispose()
    
    Write-Host "Finished gathering storage information for:" $Site
    
};
