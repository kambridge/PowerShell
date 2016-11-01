#Delete orphaned databases
#Description:
#Notes: 

#After deleting the offended dbs run this command to upgrade the content database
Upgrade-SPContentdatabase -Identity <contentdatabase>

#Run PSConfig.exe
PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures
