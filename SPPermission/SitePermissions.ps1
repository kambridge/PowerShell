#GET SITE PERMISSIONS 
#DESCRIPTION: This creates the column heading in the csv file called UserPermissionsRpt.csv
#NOTES:

"Resource `t  Granted By `t  Username `t User `t Permissions `t  Email" | out-file ".\UserPermissionsRpt.csv" -append

function StartPermissions (){
  #Get Web Application
  $webapps = Get-SPWebapplication 
  #$OutputFile = $OutputFile.ToLower()

  foreach ($webapp in $webapps){	

    foreach($site in Get-SPSite  -WebApplication $webapp -limit all) {
      $urlWeb = $site.url
      $OutputFile = $OutputFile.ToLower()
      #$webapp = $webapp.ToLower()	
      $SelectedUser = Get-SPUser -Web $urlWeb -Limit all

      $SharePointObject = Get-SPWeb $urlWeb
      #$Array = @()  This is no longer needed
      Foreach($subUser in $SelectedUser){
          if($subUser -like "*\*"){
              # Set the users login name
              $loginName = $subUser.LoginName
              $User = $subUser.Name
              $email = $subUser.Email

              #Get the users permission details.
        $permInfo = $SharePointObject.GetUserEffectivePermissionInfo($loginName)
			
			  # Determine the URL to the securable object being evaluated
			  $resource = $null
			    if ($SharePointObject -is [Microsoft.SharePoint.SPWeb]) {
				    $resource = $SharePointObject.Url
			    } elseif ($SharePointObject -is [Microsoft.SharePoint.SPList]) {
				    $resource = $SharePointObject.ParentWeb.Site.MakeFullUrl($SharePointObject.RootFolder.ServerRelativeUrl)
          } elseif ($SharePointObject -is [Microsoft.SharePoint.SPListItem]) {
				    $resource = $SharePointObject.ParentList.ParentWeb.Site.MakeFullUrl($SharePointObject.Url)
			    }

        # Get the role assignments and iterate through them
        $roleAssignments = $permInfo.RoleAssignments
            
			  if ($roleAssignments.Count -gt 0) {
          foreach ($roleAssignment in $roleAssignments) {
            $member = $roleAssignment.Member
            # Build a string array of all the permission level names
            $permName = @()
            # Determine how the users permissions were assigned
            $assignment = "Direct Assignment"
            if ($member -is [Microsoft.SharePoint.SPGroup]) {
              $assignment = $member.Name
            } else {
              if ($member.IsDomainGroup -and ($member.LoginName -ne $loginName)) {
                $assignment = $member.LoginName
              }
            }
        #Create a hash table with all the data
        foreach ($definition in $roleAssignment.RoleDefinitionBindings) {
          $permName  = $definition.Name
            " $($resource) `t  $($assignment) `t  $($subuser) `t $($user) `t $($permName) `t  $($email)" | out-file ".\UserPermissionsRpt.csv" -append
            #"`t  `t  `t  $($user.LoginName)  `t  $($user.name) `t  $($user.Email)" | out - file ".\UsersandGroupsRpt.txt" - append
						#$row = New-Object PSObject -Property @{"Granted By" = $assignment;"User Name" = $subUser;User = $User;Email = $email;Resource = $resource;Permission = $permName}
            #$Array += $row

        }
      }
    }
  }
}
    #$Array | out-file $OutputFile -append #|format-table -property * -autosize -wrap
}
}
}

 #Displaying to the user the location of the Report file
 Write-Host "User Report file is located at .\UserPermissionsRpt.csv"
 
 StartPermissions
