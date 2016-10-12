<#
Convert to Claims
Description: How to convert a web app to Claims
#>

<#Step 1 - Install Cert to the web servers#>
.\InstallCerts.ps1 -realm "<urn>" -webapp "<url>"

#Step 2 - Upgrade web app to Claims
.\UpgradeToClaims.ps1 -webapp "<url>" -user "<domain\farmaccount>"

<#
Step 3 – In CA, select ADFS Trust Provider for the web app.
How to remove Trusted Identity Provider.
Note: Deselect it from the web app first.
#>
Remove-SPTrustedIdentityTokenIssuer "<ADFS Identity>"

#How to Add second Realm of a second web app to the same Trusted Identity Provider
$ap = Get-SPTrustedIdentityTokenIssuer -Identity "<ADFS Identity>"
$uri = new-object System.Uri("<url>")
$ap.ProviderRealms.Add($uri, "<urn>")
$ap.Update()

#To list DefaultProviderRealms and other added ProviderRealms
$ap
