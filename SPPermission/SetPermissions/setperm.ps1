#SET USER PERMISSIONS
#DESCRIPTION: PowerShell Script to add user permissions to site and lists/libraries
#NOTES:

#Get Content from XML file
Param([string] $filepath = ".\setpermschema.xml")

#Start Function 
function Start-SetPermissions(){

  #Start user assignment: open web
  [xml] $config = Get-Content $filepath
  Write-Host ("Getting content from " + $filepath)
  #Snapin
  Add-PsSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue

  #Loop through each web node to open web
  $config.Items.Item | ForEach-Object {

  Write-Host "Getting web object $($_.Url)..."
  $SharePointObject = Get-SPWeb $_.SharePointObject

  #Domain\UserName
  if($_.gname -like "*\*"){
  #What is the SP Object 
  # Determine the URL to the securable object being evaluated
  $resource = $null
  if ($SharePointObject -is [Microsoft.SharePoint.SPWeb]) {
    $resource = $SharePointObject.Url
    $site = Get-SPSite -Identity $_SharePointObject
    $user = Get-SPUser -Identity $_.account -Web $site.RootWeb
    $role = $site.RootWeb.RoleDefinitions[$_.role]
    $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($user)
    $assignment.RoleDefinitionBindings.Add($role);
      foreach ($web in $site.AllWebs) {
            if ($web.HasUniquePerm) {
                $web.RoleAssignments.Add($assignment)
            } 
      }
  } 
  elseif ($SharePointObject -is [Microsoft.SharePoint.SPList]) {
    $resource = $SharePointObject.ParentWeb.Site.MakeFullUrl($SharePointObject.RootFolder.ServerRelativeUrl)		
    Write-host "Setting permissions to list..."
    $account = $web.EnsureUser($_.account)
    Write-host "get role"
    $role = $web.RoleDefinitions[$_.role]
    write-host "getting list..."
    $list = Get-SpList -url $_.SharePointObject
    $listname = $list.Title
    $getlist = $SharePointObject.Lists[$listname]
    $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($account)
    $assignment.RoleDefinitionBindings.Add($role)
    $getlist.RoleAssignments.Add($assignment)
    $getlist.Update()
	} 
	elseif ($SharePointObject -is [Microsoft.SharePoint.SPListItem]) {
		$resource = $SharePointObject.ParentList.ParentWeb.Site.MakeFullUrl($SharePointObject.Url)
		Write-host "Setting permissions to list..."
		$account = $web.EnsureUser($_.account)
      Write-host "get role"
      $role = $web.RoleDefinitions[$_.role]
      $list = Get-SpList -url $_.SharePointObject
      $item = $list.items | where {$_.SharePointObject -eq $item.url}
      $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($account)
      $assignment.RoleDefinitionBindings.Add($role)
      $item.RoleAssignments.Add($assignment)
      $item.update()
    }
  }
  elseif($_.gname -is [Microsoft.SharePoint.SPGroup){
    $SharePointObject = Get-SPWeb $_.SharePointObject
    $SharePointObjectweb = $SharePointObject.openweb()
    $groupname = $SharePointObjectweb.SiteGroups[$_.gname]
    $groupname.AllowMembersEditMembership = $true
    $groupname.update()
    Write-Host "Add Member"
    $user = New-SPUser $_.account -web $SharePointObject
    $groupname.AddUser($user)

    $resource = $null
    if ($SharePointObject -is [Microsoft.SharePoint.SPWeb]) {
      $resource = $SharePointObject.Url
      $site = Get-SPSite -Identity $_SharePointObject
      $groupname = $SharePointObjectweb.SiteGroups[$_.gname]
      #$user = Get-SPUser -Identity $_.account -Web $site.RootWeb
      $role = $site.RootWeb.RoleDefinitions[$_.role]
      $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($groupname)
      $assignment.RoleDefinitionBindings.Add($role);

        foreach ($web in $site.AllWebs) {
              if ($web.HasUniquePerm) {
                  $web.RoleAssignments.Add($assignment)
              } 
        }
    } 
    elseif ($SharePointObject -is [Microsoft.SharePoint.SPList]) {
      $resource = $SharePointObject.ParentWeb.Site.MakeFullUrl($SharePointObject.RootFolder.ServerRelativeUrl)		
      Write-host "Setting permissions to list..."
      $groupname = $SharePointObjectweb.SiteGroups[$_.gname]
      Write-host "get role"
      $role = $web.RoleDefinitions[$_.role]
      write-host "getting list..."
      $list = Get-SpList -url $_.SharePointObject
      $listname = $list.Title
      $getlist = $SharePointObject.Lists[$listname]
		  $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($groupname)
		  $assignment.RoleDefinitionBindings.Add($role)
		  $getlist.RoleAssignments.Add($assignment)
		  $getlist.Update()
	  } 
	  elseif ($SharePointObject -is [Microsoft.SharePoint.SPListItem]) {
		$resource = $SharePointObject.ParentList.ParentWeb.Site.MakeFullUrl($SharePointObject.Url)
		write-host "setting permissions to item..."
		$groupname = $SharePointObjectweb.SiteGroups[$_.gname]
		$list = Get-SpList -url $_.SharePointObject
		$item = $list.items | where {$_.SharePointObject -eq $item.url}
		$assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($groupname)
		$assignment.RoleDefinitionBindings.Add($role)
		$item.RoleAssignments.Add($assignment)
		$item.update()
	  }
	}
}
