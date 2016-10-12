<#--POWERSHELL TEMPLATE--#>
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
