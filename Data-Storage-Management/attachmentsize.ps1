#Get Attachment Size
#Description: Get size of all attachments in a site collection.
#Note: Update file path ($filepath) and site collection url ($siteurl).

function Get-DocInventory() {
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

$filepath = "<path>\attachmentsize.txt"
$siteurl = "<url>"
$site = Get-SPSite -Identity $siteurl

    foreach ($web in $site.AllWebs){
        
        foreach ($list in $web.lists){
            if ($list.BaseType -eq "DocumentLibrary") {
                foreach ($item in $list.Items) {
                    $data = @{
                        "Site" = $site.Url
                        "Web" = $web.Url
                        "list" = $list.Title
                        "Item ID" = $item.ID
                        "Item URL" = $item.Url
                        "Item Title" = $item.Title
                        "File Size KB" = $item.File.Length/1KB
                        "File Size MB" = $item.File.Length/1MB
                        "Item Created" = $item["Created"]
                        "Item Modified" = $item["Modified"]
                    }
                    New-Object PSObject -Property $data
                }   
            }            
        $web.Dispose();
        }
    $site.Dispose()
    }
}
Get-DocInventory | Out-GridView
#Get-DocInventory | Export-Csv -NoTypeInformation -Path $filepath
