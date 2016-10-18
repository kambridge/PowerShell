<# TITLE: Configure "Manage Access Requests for each site in a web application
DESCRIPTION: The script gets all webs and sets the request access email.
EXPORT FILE (*PARAMETER): Make sure the file path for the csv is specified (i.e. "-filepath").
WEB APPLICATION (*PARAMETER): Make sure the web application path is specified (i.e. "-webappurl").
ACCESS REQUEST EMAIL (*PARAMETER): Identify the e-mail address to send all requests for access.
RUNNING THE SCRIPT INSTRUCTIONS: Open a SharePoint Management Shell as an Administrator. Go to the the directory the script lives in. Start by using ".\": 
***EXAMPLE:*** .\accessrequestconfig.ps1 -webappurl "https://webappurl.com" -filepath "c:\csvfilepath.csv" -email "user@domain.com"
#>

#Create param for web application
Param([string] $webappurl = $("Please specify a web application URL"),
[string] $filepath = $("Please specify a file path"),
[string] $email = $("Please specify an e-mail address"))

#Check to see if the SharePoint snapin is loaded.  If not, load it.
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
                Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
                "NOTE: this utility should be run from the Sharepoint Management Console"
}

#Now check to see if it loaded successfully.  If not, alert the user and exit
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
                Write-Error("Unable to load the Sharepoint snap-in.  Please ensure that you are running this utility on a server with Sharepoint installed")
                Write-Error("Also try to run this utility from the SharePoint Management Console")
                exit 101
}

function Start-ManageAccessRequestsEmail() {
$webapp = Get-SPWebApplication $webappurl
	foreach ($SPSite in $webapp.Sites){
	$SPSite = Get-SPSite $SPSite
		foreach ($SPWeb in $SPSite.AllWebs){  
            if ($SPWeb.HasUniqueRoleAssignments){
    			#Getting the Web URL
    			$SPWebURL = $SPWeb.URL
    			#Set the variable for the CRC email account
    			$CRCEmail = $email
    			#Enabling Request Access and Setting the Request Access Email
    			$SPWeb.RequestAccessEmail = $CRCEmail
    			$RequestAccessEmail = $SPWeb.RequestAccessEmail
    			$SPWeb.Update()			
                # Create a hash table with all the data
                $hash = @{
        			"Web URL" = $SPWebURL
                    "Request Access Email" = $RequestAccessEmail
        		}
        		# Convert the hash to an object and output to the pipeline
                New-Object PSObject -Property $hash           
            }
        #Dispose of the web object            
        $SPWeb.Dispose();
		}
    #Dispose of the spsite object        
    $SPSite.Dispose();
	}
}

#Execute the script
Start-ManageAccessRequestsEmail | Export-Csv -NoTypeInformation -Path $filepath 



