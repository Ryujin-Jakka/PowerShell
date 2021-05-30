Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

Function GetUserAccessReport($WebAppURL, $SearchUser, [Switch]$verbos){
    $writeHostPrefixCount = 0
    $writeHostPrefixType = "  "
    #Output Report location
    $OutputReport = "$PSScriptRoot\UserAccessReport.csv"

    #delete the file, If already exist!
    if (Test-Path $OutputReport) {
        Remove-Item $OutputReport
    }

    if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning Farm Administrator Group..." }

    #Write CSV- TAB Separated File) Header
    "URL`tSite/List`tTitle`t PermissionType`tPermissions" | out-file $OutputReport

    ####Check Whether the Search Users is a Farm Administrator ###
    #Get the SharePoint Central Administration site
    $AdminWebApp= Get-SPwebapplication -includecentraladministration | ? {
        $_.IsAdministrationWebApplication
    }

    $AdminSite = Get-SPweb $AdminWebApp.Url
    $AdminGroupName = $AdminSite.AssociatedOwnerGroup
    $FarmAdminGroup = $AdminSite.SiteGroups[$AdminGroupName]

    #enumerate in farm adminidtrators groups
    foreach ($user in $FarmAdminGroup.users) {
        if($user.LoginName -eq $SearchUser) {
            "$($AdminWebApp.URL)`tFarm`t$($AdminSite.Title)`t Farm Administrator`tFarm Administrator" | Out-File $OutputReport -Append
        }    
    }

    ### Check Web Application Policies ###
    if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning Web Application Policies..." }
    $WebApp= Get-SPWebApplication $WebAppURL

    foreach ($Policy in $WebApp.Policies) {
        #Check if the search users is member of the group
        if($Policy.UserName -eq $SearchUser) {
            [Integer]$writeHostPrefixCount = 1
            if($verbos){ Write-Host $($writeHostPrefixType*$writeHostPrefixCount)$Policy.UserName -ForegroundColor Red }
            $PolicyRoles=@()
            foreach($Role in $Policy.PolicyRoleBindings) {
                $PolicyRoles+= $Role.Name +";"
            }
            if($verbos){ Write-Host "$($writeHostPrefixType*$writeHostPrefixCount)Permissions: " $PolicyRoles -ForegroundColor Red }
            "$($AdminWebApp.URL)`tWeb Application`t$($AdminSite.Title)`t  Web Application Policy`t$($PolicyRoles)" | Out-File $OutputReport -Append
        }
    }

    $writeHostPrefixCount = 0
    if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning Site Collections..." }
    #Get All Site Collections of the WebApp
    $SiteCollections = Get-SPSite -WebApplication $WebAppURL -Limit All

    #Loop through all site collections
    foreach ($Site in $SiteCollections) {
        $writeHostPrefixCount = 1
        if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning Site Collection:" $site.Url }
        #Check Whether the Search User is a Site Collection Administrator
        foreach ($SiteCollAdmin in $Site.RootWeb.SiteAdministrators) {
            if($SiteCollAdmin.LoginName -eq $SearchUser) {
                "$($Site.RootWeb.Url)`tSite`t$($Site.RootWeb.Title)`t Site Collection Administrator`tSite Collection Administrator" | Out-File $OutputReport -Append
            }    
        }

        #Loop throuh all Sub Sites
        foreach ($Web in $Site.AllWebs) {
            $writeHostPrefixCount = 2
            if($Web.HasUniqueRoleAssignments -eq $True) {
                if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning Site:" $Web.Url }

                #Get all the users granted permissions to the list
                foreach($WebRoleAssignment in $Web.RoleAssignments ) {
                    $writeHostPrefixCount = 3
                    #Is it a User Account?
                    if($WebRoleAssignment.Member.userlogin) {
                        #Is the current user is the user we search for?
                        if($WebRoleAssignment.Member.LoginName -eq $SearchUser) {
                            if($verbos){ Write-Host  $($writeHostPrefixType*$writeHostPrefixCount)$SearchUser has direct permissions to site $Web.Url -ForegroundColor Red }
                            #Get the Permissions assigned to user
                            $WebUserPermissions=@()
                            foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings) {
                                $WebUserPermissions += $RoleDefinition.Name +";"
                            }
                            if($verbos){ write-host "$($writeHostPrefixType*$writeHostPrefixCount)with these permissions: " $WebUserPermissions -ForegroundColor Red }

                            #Send the Data to Log file
                            "$($Web.Url)`tSite`t$($Web.Title)`t Direct Permission`t$($WebUserPermissions)" | Out-File $OutputReport -Append
                        }
                    }
                    #Its a SharePoint Group, So search inside the group and check if the user is member of that group
                    else {
                        foreach($user in $WebRoleAssignment.member.users) {
                            #Check if the search users is member of the group
                            if($user.LoginName -eq $SearchUser) {
                                if($verbos){ Write-Host  "$($writeHostPrefixType*$writeHostPrefixCount)$SearchUser is Member of " $WebRoleAssignment.Member.Name "Group" -ForegroundColor Red }
                                #Get the Group's Permissions on site
                                $WebGroupPermissions=@()
                                foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings) {
                                    $WebGroupPermissions += $RoleDefinition.Name +";"
                                }
                                if($verbos){ write-host "$($writeHostPrefixType*$writeHostPrefixCount)Group has these permissions: " $WebGroupPermissions -ForegroundColor Red }

                                #Send the Data to Log file
                                "$($Web.Url)`tSite`t$($Web.Title)`t Member of $($WebRoleAssignment.Member.Name) Group`t$($WebGroupPermissions)" | Out-File $OutputReport -Append
                            }
                        }
                    }
                }
            }

            ###*****  Check Lists with Unique Permissions *******###
            foreach($List in $Web.lists) {
                $writeHostPrefixCount = 3
                if($List.HasUniqueRoleAssignments -eq $True -and ($List.Hidden -eq $false)) {
                    if($verbos){ Write-host "$($writeHostPrefixType*$writeHostPrefixCount)Scanning List:" $List.RootFolder.Url }
                    #Get all the users granted permissions to the list
                    foreach($ListRoleAssignment in $List.RoleAssignments ) {
                        $writeHostPrefixCount = 4
                        #Is it a User Account?
                        if($ListRoleAssignment.Member.userlogin) {
                            #Is the current user is the user we search for?
                            if($ListRoleAssignment.Member.LoginName -eq $SearchUser) {
                                if($verbos){ Write-Host  $($writeHostPrefixType*$writeHostPrefixCount)$SearchUser has direct permissions to List ($List.ParentWeb.Url)/($List.RootFolder.Url) -ForegroundColor Red }
                                #Get the Permissions assigned to user
                                $ListUserPermissions=@()
                                foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings) {
                                    $ListUserPermissions += $RoleDefinition.Name +";"
                                }
                                if($verbos){ write-host "$($writeHostPrefixType*$writeHostPrefixCount)with these permissions: " $ListUserPermissions -ForegroundColor Red }

                                #Send the Data to Log file
                                "$($List.ParentWeb.Url)/$($List.RootFolder.Url)`tList`t$($List.Title)`t Direct Permissions`t$($ListUserPermissions)" | Out-File $OutputReport -Append
                            }
                        }
                        #Its a SharePoint Group, So search inside the group and check if the user is member of that group
                        else {
                            foreach($user in $ListRoleAssignment.member.users) {
                                if($user.LoginName -eq $SearchUser) {
                                    if($verbos){ Write-Host  "$($writeHostPrefixType*$writeHostPrefixCount)$SearchUser is Member of " $ListRoleAssignment.Member.Name "Group" -ForegroundColor Red }
                                    #Get the Group's Permissions on site
                                    $ListGroupPermissions=@()
                                    foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings) {
                                        $ListGroupPermissions += $RoleDefinition.Name +";"
                                    }
                                    if($verbos){ write-host "$($writeHostPrefixType*$writeHostPrefixCount)Group has these permissions: " $ListGroupPermissions -ForegroundColor Red }

                                    #Send the Data to Log file
                                    "$($Web.Url)`tSite`t$($List.Title)`t Member of $($ListRoleAssignment.Member.Name) Group`t$($ListGroupPermissions)" | Out-File $OutputReport -Append
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Write-host "`n Access Rights Report Generated!" -ForegroundColor Green
}


#Call the function to Check User Access
GetUserAccessReport "SITE URL" "i:0#.w|DOMAIN\USERNAME\"