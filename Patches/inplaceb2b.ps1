#PSConfig
#Description: Open cmd as Administrator and run below command after installing Sharepoint Updates/paches. 
#Check CA for servers that need to be upgraded: CA > System Settings > Manage servers in the farm > Upgrade Server
#Notes: Run one server at a time.


PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures
