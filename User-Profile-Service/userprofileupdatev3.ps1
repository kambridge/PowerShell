<#TITLE: Get users in User Information list and run it against the User Profile Service. Creates a hash with user data.
*Must have "full control" permissions to the User Profile Service Application to run script. #>

# ***EXAMPLE:*** .\userprofileupdatev3.ps1 -siteurl "https://siteurl.com" 

#Create param for site collection
Param([string] $siteurl = $("Please specify a site collection URL"))

[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Server");

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

#function Sync-SPUser([string]$userName, [string]$title) {
function Sync-SPUser([string]$userName) {
    $sitecol = Get-SPSite $siteurl
    Write-Host $sitecol
    #Get-SPSite -Limit All | foreach {
    $web = $sitecol.RootWeb
    $list = $web.Lists["User Information List"]
    Write-Host "List Name: " $list.Title
        foreach ($item in $list.GetItems()){
            #Get users in list.
            $accountname = $item["Name"]
            #Write-Host "Account Name: " $accountname
            $accountDepartment = $item["Department"]
            #Write-Host "UIL Account Department: " $accountDepartment
            $accountjob = $item["JobTitle"]
            #Write-Host "UIL Account Job Title: " $accountjob
            $accountoffice = $item["Office"]           
            #Write-Host "UIL Account Office: " $accountoffice           
            #if(($accountDepartment -eq $null) -Or ($accountjob -eq $null) -Or ($accountoffice -eq $null)){
                Write-Host "-----Begin User Profile Info-----"
                Write-Host "Account Name: " $accountname -foregroundcolor "yellow"
                #User Profile Service
                $servicecontext = Get-SPServiceContext $sitecol
                #UPS:  Get UserProfile namespace
                $ups = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($servicecontext)
                #Get Profile Properties
                #$userProfile.Properties | sort DisplayName | FT DisplayName,Name
                #Get user profile with Account Name                
                try {
                    $userProfile = $ups.GetUserProfile($accountname)
                    #Get user profile info
                    $useroffice = $userProfile["Office"].Value
                    #Write-Host "User Profile Service Office Value: " $useroffice   
                    $userdept = $userProfile["Department"].Value
                    #Write-Host "User Profile Service Department Value: " $userdept
                    $usertitle = $userProfile["Title"].Value
                    #Write-Host "User Profile Service Title Value: " $usertitle
                                      
                    #Create hash 
                    $hash = @{
                        "User Profile Service" = "Active"
                        "User Account" = $accountname
                        "UIL Title" = $accountjob
                        "UPS Title" = $usertitle
                        "UIL Office" = $accountoffice
                        "UPS Office" = $useroffice 
                        "UIL Department" = $accountDepartment                        
                        "UPS Department" = $userdept 
                        
                    }
                    # Convert the hash to an object and output to the pipeline
                    New-Object PSObject -Property $hash                   
                }
                Catch{
                    #Write-Host "Error - User Profile was not update:" $accountname
                    #Create hash 
                    $hash = @{
                        "User Profile Service" = "Removed"
                        "User Account" = $accountname
                    }
                    # Convert the hash to an object and output to the pipeline
                    New-Object PSObject -Property $hash 
                }
            #}
        }         
    $web.Dispose()
    Write-Host "web dispose"
    $sitecol.Dispose()
    Write-Host "site dispose"
}

#Execute the script
Sync-SPUser | Export-Csv -NoTypeInformation -Path "D:\Scripts\userprofilesdatav3.csv"
