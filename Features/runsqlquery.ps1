<# QUERY SQL TO CAPTURE SP FEATURE
DESCRIPTION: Run SQL Query to locate specific feature on site collections and webs.
NOTES: Change <featurepath>, <id>, <database> and <instance>
#>

function Run-SQLQuery ($SqlServer, $SqlDatabase, $SqlQuery)
{
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server =" + $SqlServer + "; Database =" + $SqlDatabase + "; Integrated Security = True"
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()
    $DataSet.Tables[0]
}
#Run-SQLQuery -SQLServer "<instance>" -SqlDatabase "<database>" -SqlQuery "SELECT * from AllDocs where SetupPath = 'Features\<feature>'" | select Id, SiteId, DirName, LeafName, WebId, ListId | Format-List

$site = Get-SPSite -Limit all | where { $_.Id -eq "<id>" }

$web = $site | Get-SPWeb -Limit all | where { $_.Id -eq "<id>" }

$web.Url
