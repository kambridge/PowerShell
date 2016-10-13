<#
[MissingFeature] Database [SharePoint_Content_Portal] has reference(s) to a missing feature: Id = [8096285f-1463-42c7-82b7-f745e5bacf29], 
Name = [My Feature], Description = [], Install Location = [Test-MyFeature]. 
The feature with Id 8096285f-1463-42c7-82b7-f745e5bacf29 is referenced in the database [SharePoint_Content_Portal], but is not installed on the current farm. 
The missing feature may cause upgrade to fail. Please install any solution which contains the feature and restart upgrade if necessary.
#>

<#    NOTES: Removes feature from all site collections and sites    #>

function Remove-SPFeatureFromContentDB($ContentDb, $FeatureId, [switch]$ReportOnly)
{
    $db = Get-SPDatabase | where { $_.Name -eq $ContentDb }
    [bool]$report = $false
    if ($ReportOnly) { $report = $true }
    
    $db.Sites | ForEach-Object {
        
        Remove-SPFeature -obj $_ -objName "site collection" -featId $FeatureId -report $report
                
        $_ | Get-SPWeb -Limit all | ForEach-Object {
            
            Remove-SPFeature -obj $_ -objName "site" -featId $FeatureId -report $report
        }
    }
}

function Remove-SPFeature($obj, $objName, $featId, [bool]$report)
{
    $feature = $obj.Features[$featId]
    
    if ($feature -ne $null) {
        if ($report) {
            write-host "Feature found in" $objName ":" $obj.Url -foregroundcolor Red
        }
        else
        {
            try {
                $obj.Features.Remove($feature.DefinitionId, $true)
                write-host "Feature successfully removed from" $objName ":" $obj.Url -foregroundcolor Red
            }
            catch {
                write-host "There has been an error trying to remove the feature:" $_
            }
        }
    }
    else {
        #write-host "Feature ID specified does not exist in" $objName ":" $obj.Url
    }
}

Remove-SPFeatureFromContentDB -ContentDB "SharePoint_Content_Portal" -FeatureId "8096285f-1463-42c7-82b7-f745e5bacf29" -ReportOnly
#Remove-SPFeatureFromContentDB -ContentDB "SharePoint_Content_Portal" -FeatureId "8096285f-1463-42c7-82b7-f745e5bacf29"
