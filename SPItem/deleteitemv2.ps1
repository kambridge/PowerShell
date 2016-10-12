<#--- DELETE ITEMS IN A LIST ---#>
<#--- IMPORTANT ---#> 
<#--- MAKE SURE YOU DOCUMENT THE CORRECT LIST AS THIS SCRIPT IS DESIGNED TO DELETE ALL ITEMS IN A LIST --#>
<#--- IMPORTANT ---#>
<#--DESCRIPTION: After identifying the site collection parameter ($SiteUrl) and list parameter ($ListGUID), 
the script retrives the web application, site collection and web in order to get the list. Once the list is retrieve the script deletes ALL items in the list. ---#>

<#---RUN EXAMPLE: ---#>
#PS C:\"location of script" > .\DeleteListItems.ps1 -SiteUrl "Site list is located" -ListGUID "GUID of List"

#Create Site Url Parameter 
Param([string]$Siteurl = "<url>", [string]$ListGUID = "<listguid>")

if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
                Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
                "NOTE: this utility should be run from the Sharepoint Management Console"

}

#Confirm Site Url Parameter
Write-Host "Site Url:" $Siteurl

#Get Web
$Rootweb = New-Object Microsoft.Sharepoint.SPSite($Siteurl);
#Write-Host $Rootweb

<#--Retrieve Items and delete from a single list---#>
#Get Web
Foreach ($Web in $Rootweb.AllWebs){
    Foreach ($List in $Web.Lists){    
        if ($List.ID -eq $ListGUID){
            #Gets Name and ID of List     
            Write-Host $List.Title $List.ID
            #Write-Host $List.Items;
            $Listitems = $List.Items;
            $ListCount = $Listitems.Count;   
            For ($itemindex = $ListCount-1;$itemindex -ge 0;$itemindex--){
                Write-Host ("DELETED:" + $Listitems[$itemindex].name)
                $Listitems[$itemindex].Delete();
            }

        }    
    };
};
$web.Dispose();
#$site.Dispose();
