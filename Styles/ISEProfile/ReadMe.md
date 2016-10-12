###Create ISE Profile Color Theme
**Reference** [How to Use Profiles in Windows PowerShell ISE](https://technet.microsoft.com/en-us/%5Clibrary/Dd819434.aspx)

**Directory where scripts are store**
$psdir = ".\KGDocuments\PowershellISE\Scripts\autoload"

**Load all 'autoload' scripts**
Get-ChildItem "${psdir}\*.ps1" | %{.$_}
