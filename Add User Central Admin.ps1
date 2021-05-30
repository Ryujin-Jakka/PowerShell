$SiteURL = "SITEURL"
$UserLogin="domain\username"

$Context  = Get-SPServiceContext -site $SiteURL
#Do not worry if the $Context returns a GUID full of 0s, it is completely normal

$UserProfileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($Context)
#Need permissions to access and make changes to the User Profile Service
 
#We can then retrieve the user profile...
$UserProfileManager.GetUserProfile($UserLogin)
#... or go straigth to the deletion
$UserProfileManager.RemoveUserProfile($UserLogin)