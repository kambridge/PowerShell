#Get size of Site Collection
#Description: Get size of all site collections in a web application.
#Note: Change file path ($path) and site collection urls ($SQSiteColls).

function SiteCollections(){
Write-Host "Site Quota Function Started"
$SQSiteColls = "<url>", "<url>"
$SQSites= $SQSiteColls

  foreach ($SQSite in $SQSites){
    $Rootweb = [Microsoft.Sharepoint.Administration.SPWebApplication]::Lookup($SQSite);
        #$Webapp = $Rootweb.WebApplication;
        #Loops through each site collection within the Web app
        foreach ($Site in $Rootweb.Sites){         
            #Is Quota greater than 0
            if ($Site.Quota.StorageMaximumLevel -gt 0) {
                $MaxStorage = $Site.Quota.StorageMaximumLevel /1MB
            }else {
                $MaxStorage="0"
            }           
            #Quota greater than 0 
            if ($Site.Usage.Storage -gt 0) {
                $StorageUsed = $Site.Usage.Storage /1MB
            }            
            #Quota greater than 0 and Max Storage greater than 0
            if ($StorageUsed -gt 0 -and $MaxStorage -gt 0){
                $SiteQuotaUsed = $StorageUsed/$MaxStorage* 100
            } 
            else{
                $SiteQuotaUsed = "0"
            }
            $Web = $Site.Rootweb;
            $StorageUsedGB = $StorageUsed/1024               
            #Create Hash 
            $hash = @{
                "Site Url" = $Site.Url
                "Site Content Database" = $Site.contentdatabase
                "Quota Limit (MB)" = $MaxStorage
                "Total Storage Used (MB)" = $StorageUsed
                "Total Storage Used (GB)" = $StorageUsedGB 
            }
            
            # Convert the hash to an object and output to the pipeline
            New-Object PSObject -Property $hash
            $Site.Dispose()      
        }
        Write-Host "Site Quota Function Ended"
  }
}
#Site Quota Path
$sqpath = "<path>\sitecollections.txt"
SiteCollections | Export-Csv -NoTypeInformation -Path $sqpath
