#Get Site Collections in Database and Size
#Description:
#Notes:


#Get all site collection for database

Get-SPSite -Limit All -ContentDatabase <database name> | select url, @{label="Size in MB";Expression={$_.usage.storage/1024/1024}}
