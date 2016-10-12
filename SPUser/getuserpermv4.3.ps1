<#
TITLE: Get user permissions for each site in a web application. 
DECRIPTION: The script gets user permissions for all sites within a web application. A parameter is created for the web app url (i.e. -webappurl). The data is outputed to a CSV file. The current path of the csv file is "c:\perms.csv". To change the path of the csv file go to the line before "$site.Dispose()" in this script. 
DEPLOYMENT INSTRUCTIONS: Open a SharePoint Management Shell as an Administrator. Go to the the directory the script lives in. Start by using ".\": for example .\getuserpermv4.1.ps1 -webappurl "https://webappurl.com" ACCESS ERRORS: Refer to the following link: http://support.microsoft.com/kb/896148/en-us
OUTPUT FILES: PERMS.CSV and PERMSFIX.CSV
#>

#Create param for web application
    param([string] $webappurl = $("Please specify a web application URL"))

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
<#Calling the SPSecurableObject in order to retrieve the permissions from each site in the web application#>
function Get-SPUserPermissions(
    [object[]]$users, 
    [Microsoft.SharePoint.SPSecurableObject]$InputObject) {   
    begin { }
    process {
        $so = $InputObject
        if ($so -eq $null) { $so = $_ }

        if ($so -isnot [Microsoft.SharePoint.SPSecurableObject]) {
        throw "A valid SPWeb, SPList, or SPListItem must be provided."
        }
        #Get each user
        foreach ($user in $users) {
            
            # Set the users login name, email, and display name
            $loginName = $user
            if ($user -is [Microsoft.SharePoint.SPUser] -or $user -is [PSCustomObject]) {
            $loginName = $user.LoginName
            $useremail = Get-SPUser -Web $so -Identity $loginName | select Email
            $username = Get-SPUser -Web $so -Identity $loginName | select DisplayName
            }
            if ($loginName -eq $null) {
            throw "The provided user is null or empty. Specify a valid SPUser object or login name."
            }
            
            # Get the users permission details.
            $permInfo = $so.GetUserEffectivePermissionInfo($loginName)

            # Determine the URL to the securable object being evaluated
            $resource = $null
            if ($so -is [Microsoft.SharePoint.SPWeb]) {
                $resource = $so.Url
                $roleAssignments = $permInfo.RoleAssignments
                    if ($roleAssignments.Count -gt 0) {
                        foreach ($roleAssignment in $roleAssignments) {
                        $member = $roleAssignment.Member
                        # Build a string array of all the permission level names
                        $permName = @()
                            foreach ($definition in $roleAssignment.RoleDefinitionBindings) {
                            $permName += $definition.Name
                            }

                        # Determine how the users permissions were assigned
                        $assignment = "Direct Assignment"
                        if ($member -is [Microsoft.SharePoint.SPGroup]) {
                        $assignment = $member.Name
                        } else {
                        if ($member.IsDomainGroup -and ($member.LoginName -ne $loginName)) {
                        $assignment = $member.LoginName
                        }
                        }
                        # Create a hash table with all the data
                        $hash = @{
                            Resource = $resource;
                            "Resource Type" = $so.GetType().Name;
                            User = $loginName;
                            "User Name" = $username ;
                            Email = $useremail;
                            Permission = $permName -join ", ";
                            "Granted By" = $assignment    
                        }
                # Convert the hash to an object and output to the pipeline
                New-Object PSObject -Property $hash
                }
            }
		}
        }
        }
    end {}
}

$gc = Start-SPAssignment
#Set a variable to get the web application of the parameter
$webapp = Get-SPWebApplication $webappurl

#Get each site collection in the web application and get all sites (i.e. Get-SPWeb)
foreach ($site in $webapp.sites) {
$site = $gc | Get-SPSite $site
$sitepermissions += $site | Get-SPWeb –Limit All | Get-SPUserPermissions ($site.RootWeb.SiteUsers | select LoginName)
$site.Dispose()
$web.Dispose()
}
$gc | Stop-SPAssignment -Global
#Export the data from $sitepermissions to a CSV file

$sitepermissions | Export-Csv -NoTypeInformation -Path D:\perms4.csv

#$web.Dispose()
<#REPLACING VALUES IN THE CSV FILE:"
DESCRIPTION: "$sitepermissions | Export-Csv -NoTypeInformation -Path c\perms.csv produces the following output:
"Granted By","User Name","User","Resource","Permission","Resource Type","Email"
"SP Group","@{DisplayName=user@domain}","domain\user","Site Url","Permission Name","SPWeb","@{Email=user@domain}"
PERMSFIX.CSV PRODUCES THE FOLLOWING OUTPUT:
"Granted By","User Name","User","Resource","Permission","Resource Type","Email"
"SP Group","user name}","domain\user","Site Url","Permission Name","SPWeb","user@domain}"
#>
[io.file]::readalltext("D:\perms4.csv").replace("@{Email=","").replace("@{DisplayName=","").replace("}",";")|Out-File c:\perms.csv -Encoding ascii -Force



