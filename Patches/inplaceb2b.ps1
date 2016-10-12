#PSConfig
#Description: Open cmd as Administrator and run below command after installing Sharepoint Updates/paches. 
#Notes: Run one server at a time.


PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures
