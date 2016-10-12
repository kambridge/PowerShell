#Grant service account running PerformancePoint service application pool access to Content database of the new Web application using command shell.
	
$w = get-spWebapplication –identity http://newwebappUrl:port

$w.grantAccessToProcessIdentity(“domain\sp10PrfPoint”)  


#Grant service account running SSRS service application pool access to Content database of the new Web application using command shell.

$w = get-spWebapplication –identity http://newwebappUrl:port

$w.grantAccessToProcessIdentity(“domain\sp10SSRS”)  



#Grant service account running C2WTS service application pool access to Content database of the new Web application using command shell.

$w = get-spWebapplication –identity http://newwebappUrl:port

$w.grantAccessToProcessIdentity(“domain\sp10C2WTS”)  



#Grant Excel Services account permission to additional Web App Content DB.

$w = get-spWebapplication –identity http://newwebappUrl:port

$w.grantAccessToProcessIdentity(“domain\sp10Excel”)  
