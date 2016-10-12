#Error: Cannot retrieve the information for application credential key
#Description: People picker not pulling results
#Console: STSADM
#Notes: Must run the setproperty command on every web application.
#GetProperty *uses server:port
## stsadm.exe -o getproperty -propertyname peoplepicker -searchadforests -url <servername:port>
#SetPropery
##stsadm -o setapppassword -password <password>
##stsadm -osetproperty -pn peoplepicker-searchadforests -pv "<forest>,<IFPSERV account>" -url <servername:port>
#Reference: https://technet.microsoft.com/en-us/library/cc263460(v=office.12).aspx

cls
echo========
cd %commonprogramfiles%\microsoft shared\web server extension\14\bin
@echo off

stsadm -o setapppassword <password>
stsadm -o setproperty -pn peoplepicker-searchadforests -pv "<forest>,<IFPSERV account>" -url <servername:port>

echo complete
