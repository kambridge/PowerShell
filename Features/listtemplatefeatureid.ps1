<#
Get/Remove List Template Feature
DESCRIPTION: Retrieve list template and id; retrieve list template and id for all webs; get feature id; check sp feature activate
NOTE: Change <url>, <id> and <path>
#>

#RETRIEVE LIST TEMPLATE AND ID
$SPWeb = Get-SPWeb "<url>"
$SPWeb.ListTemplates | Select FeatureId, Name, type, type_client
$SPWeb.dispose()

#RETRIEVE LIST TEMPLATE AND ID FOR ALL WEBS

function webtemplates(){
$SPSite = Get-SPSite "<url>"
    foreach ($web in $SPSite.AllWebs){
        
        #Write-Host $web.url
        $template = $web.ListTemplates | Select FeatureId, Name, type, type_client, IsCustomTemplate 
        $hash = @{
            "Web Url" = $web.url 
            "template Info" = $template            
        }
        #| Select FeatureId, Name, type, type_client
        
        New-Object PSObject -Property $hash
        $SPWeb.dispose()
    }
}

webtemplates | Export-csv -NoTypeInformation -Path "<path>\webslists.csv"

#GET FEATURE BY ID

(Get-SPFeature -Id <id>  -ErrorAction SilentlyContinue) -ne $null

#CHECK SP FEATURE ACTIVATED

function Check-SPFeatureActivated
{
    param([string]$Id=$(throw "-Id parameter is required!"),
            [Microsoft.SharePoint.SPFeatureScope]$Scope=$(throw "-Scope parameter is required!"),
            [string]$Url)  
    if($Scope -ne "Farm" -and [string]::IsNullOrEmpty($Url))
    {
        throw "-Url parameter is required for scopes WebApplication,Site and Web"
    }
    $feature=$null

    switch($Scope)
    {
        "Farm" { $feature = Get-SPFeature $Id -Farm }
        "WebApplication" { $feature = Get-SPFeature $Id -WebApplication $Url }
        "Site" { $feature = Get-SPFeature $Id -Site $Url }
        "Web" { $feature = Get-SPFeature $Id -Web $Url }
    }
    #return if feature found or not (activated at scope) in the pipeline
    $feature -ne $null
}

Check-SPFeatureActivated -Id <id>  -Scope "Site" -Url "<url>"
