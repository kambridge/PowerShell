#creating new User Profiles application pool, UProfileAppPool, running with identity domain\sp10UProfile (add to Sharepoint Managed Accounts) - Recommended

new-spServiceApplicationPool -name uProfileAppPool -account domain\sp10uProfile


#Creating new User Profiles Service Application with the profiledbName from 2007 SSP database, restored in 2010 farm as sp2010_content_profile in instance SPContent, at the same time creating new Sync db and Social db (will be created on spcontent)

new-spProfileServiceApplication -applicationPool <appPoolName> -name "User Profile Service Application 1" -profiledbname <dbname> -profiledbServer <instance> -profileSyncDBname <dbname> -SocialDBname <dbname>


#Create User Profiles Service Application Proxy and add it to the default Proxy group using command shell.

new-spProfileServiceApplicationProxy -serviceApplication <userprofileserviceapp guID from above> -name "User Profile Service Application Proxy" -defaultProxyGroup


#Run  Test-SPContentDatabase prior to Mount. Output to a text file mysites.txt

Test-SPContentDatabase -name <dbname> -serverInstance <instance> -webapplication <url> > mysites.txt


#Upgrading 2007 MySites content db, <dbname> (restored from 2007 to 2010 SPContent instance) to 2010 MySites using command shell Mount-SPContentDatabase

mount-spcontentdatabase -name <dbname> -databaseServer <instance> -webapplication <url>
