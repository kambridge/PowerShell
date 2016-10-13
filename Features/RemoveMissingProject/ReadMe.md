##Remove missing dependencies, assemblies, and setup files
*Reference: http://get-spscripts.com/2011/06/diagnosing-missingsetupfile-issues-from.html

###Diagnose Remove features from a content database in SP2010
#####Description:
Solution removed from the farm before corresponding feature was deactivated from site collection and sites.
#####Error Example:
[MissingFeature] Database [SharePoint_Content_Portal] has reference(s) to a missing feature: Id = [8096285f-1463-42c7-82b7-f745e5bacf29], Name = [My Feature], Description = [], Install Location = [Test-MyFeature]. The feature with Id 8096285f-1463-42c7-82b7-f745e5bacf29 is referenced in the database [SharePoint_Content_Portal], but is not installed on the current farm. The missing feature may cause upgrade to fail. Please install any solution which contains the feature and restart upgrade if necessary.
#####Generates file:
#####Convert to XML *xsd file is located in folder

###Diagnose MissingSetupFile issues from the SP Health Analyzer
#####Description:
#####Error Example:
[MissingSetupFile] File [Features\ReviewPageListInstances\Files\Workflows\ReviewPage\ReviewPage.xoml] is referenced [1] times in the database [SharePoint_Content_Portal], but is not installed on the current farm. Please install any feature/solution which contains this file. One or more setup files are referenced in the database [SharePoint_Content_Portal], but are not installed on the current farm. Please install any feature or solution which contains these files.
#####Generates file:
#####Convert to XML *xsd file is located in folder

###Diagnose MissingWebPart/MissingAssembly issues from the SP Health Analyzer
#####Description:
#####Error Example:
Category        : MissingWebPart
Error           : True
UpgradeBlocking : False
Message         : WebPart class [4575ceaf-0d5e-4174-a3a1-1a623faa919a] is referenced [2] times in the database [SP2010_Content], but is not installed on the current farm. Please install any feature/solution which contains this web part.
Remedy          : One or more web parts are referenced in the database [SP2010_Content], but are not installed on the current farm. Please install any feature or solution which contains these web  parts.
#####Generates file:
#####Convert to XML *xsd file is located in folder
