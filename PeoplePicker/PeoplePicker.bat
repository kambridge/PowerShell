#People picker not pulling results
#STSADM
#Must run the setproperty command on every web application.

cls
echo========
cd %commonprogramfiles%\microsoft shared\web server extension\14\bin
@echo off

stsadm -o setapppassword [password]
stsadm -o setproperty -pn peoplepicker -searchadforests -pv "[forest],[IFPSERV account]" -url

echo complete
