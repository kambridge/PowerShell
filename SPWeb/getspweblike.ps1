#GET SPWEBS *LIKE
#DESCRIPTION:
#NOTES:

Get-SPWebApplication <url> | Get-SpSite -Limit All `
| Get-SPWeb -Limit All | where-object {$_.url -like "*<name>*"} | Select Url, Title | Export-csv .\sites.csv
