#Get web template
#Description:
#Notes:

$web = Get-SPWeb <url>
$web.WebTemplate + " " + $web.WebTemplateId
$web.close()
