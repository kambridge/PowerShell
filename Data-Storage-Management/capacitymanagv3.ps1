#Get size of all sites in web application. Outputs size (kb, mb, gb) of each site collection and sub-sites.
#Notes: Change filepaths (-filepath) and url (web application).

#Check to see if the SharePoint snapin is loaded.  If not, load it.
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
                Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
                "NOTE: this utility should be run from the Sharepoint Management Console"
}

#Now check to see if it loaded succesfully.  If not, alert the user and exit
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
                Write-Error("Unable to load the Sharepoint snap-in.  Please ensure that you are running this utility on a server with Sharepoint installed")
                Write-Error("Also try to run this utility from the SharePoint Management Console")
                exit 101

}

function GetWebApplicationSize () {
    #Capacity Planning
    #Web Application
    $webapp = Get-SPWebApplication "<url>"
    
    #Current Date
    $date = Get-Date -UFormat "%m_%d_%Y"
    
    #filepath
    $filepath = "<path>" + $date + "_capslogv3.txt"

    foreach ($site in $webapp.sites) {
        <#$site | Foreach-Object {
        sitequota > <path>\sitequota.txt
        }#>
        
        $contentdb = Get-SPContentDatabase -Site $site
        $web = $site.openweb()
        
        foreach ($web in $site.AllWebs) {
            #$web = Get-SPWeb $site
            [long]$total = 0            
            
            $total += WebSize -Web $web
            $total += SubWebSizes -Web $web
            
            $totalInMb = ($total/1024)/1024
            $totalInMb = "{0:N2}" -f $totalInMb
            
            #$totalInGb = (($total/1024)/1024)/1024
            #$totalInGb = "{0:N2}" -f $totalInGb
            #$outfilesub =  ("Subtotal sites below " + $webapp + "|" + $site + " is " + $total + " Bytes, which is " + $totalInMb + " MB or " + $totalInGb + " GB")
            
            $outfilesub =  ("Total Site Collection|" + $contentdb + "|" + $webapp + "|" + $site.name +"|"+ $site.url + "|" + $web.url +  "|"  + $total +  "|"  + $totalInMb)
            Write-Host $outfilesub
            
            $outfilesub | Out-File -append -filepath $filepath
            #Write-Host "Subtotal sites below" $StartWeb "is" $total "Bytes," | Out-File -append -filepath "<path>\capslog.txt"
            #write-host "which is" $totalInMb "MB or" $totalInGb "GB" | Out-File -append -filepath "<path>\capslog.txt"
            $web.Dispose()
        }
    }
}

function WebSize ($web) {
    [long]$subtotal = 0
    
    foreach ($folder in $web.Folders) {
        $subtotal += GetFolderSize -Folder $folder
    }
    
    $fullUrl = $web.url
    $site = New-Object -Type Microsoft.SharePoint.SPSite -ArgumentList $fullUrl
    $web = $site.OpenWeb()
    $contentdb = Get-SPContentDatabase -Site $site
    
    Write-Host $site.Url
    Write-Host $web.Url    
    
    $ofwebsize = ("Web Object|" + $contentdb + "|" + $webapp + "|" + $web.name +"|"+ $site.url + "|" + $web.url + "|" + $subtotal)
    $ofwebsize | Out-File -append -filepath $filepath
    
    #write-host $web.url $subtotal "KB" | Out-File -append -filepath "<path>\capslog.txt"
    $site.Dispose()
    
    return $subtotal
}

function SubWebSizes ($web) {
    [long]$subtotal = 0
    
    foreach ($subweb in $web.GetSubwebsForCurrentUser()) {
        [long]$webtotal = 0
        
        foreach ($folder in $subweb.Folders) {
            $webtotal += GetFolderSize -Folder $folder
        }
        
        $fullUrl = $web.url
        $site = New-Object -Type Microsoft.SharePoint.SPSite -ArgumentList $fullUrl
        $web = $site.OpenWeb()
        $contentdb = Get-SPContentDatabase -Site $site
        
        Write-Host $site.Url
        Write-Host $web.Url  
        
        $ofsubwebsize = ("Web Object|" +  $contentdb + "|"  + $webapp + "|" + $web.name +"|"+ $site.url + "|" + $subweb.url + "|" +  $webtotal)
        $ofsubwebsize | Out-File -append -filepath $filepath
        #write-host $subweb.url $webtotal "Bytes" | Out-File -append -filepath "<path>\capslog.txt"
        
        $subtotal += $webtotal
        $subtotal += SubWebSizes -Web $subweb
    }
    
    return $subtotal
}

function GetFolderSize ($folder) {
    [long]$folderSize = 0
    
    foreach ($file in $folder.Files) {
        $folderSize += $file.Length;
    }
    
    foreach ($fd in $folder.SubFolders) {
        $folderSize += GetFolderSize -Folder $fd
    }    
    return $folderSize
}

GetWebApplicationSize
