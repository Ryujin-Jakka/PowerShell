Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
$taxonomySession = Get-SPTaxonomySession -Site "SITE URL"
$termStore = $taxonomySession.TermStores["Managed Metadata Service Application Proxy"]
$admins = $termStore.TermStoreAdministrators | Where-Object {$_.PrincipalName -contains $env:USERNAME}
if($admins -eq $null){
	$termStore.AddTermStoreAdministrator($env:USERNAME)
	$termStore.CommitAll()
}

function AddAdminToTermStore($webAppUrl, $mmsProxyName){
	$taxonomySession = Get-SPTaxonomySession -Site $webAppUrl, $mmsProxyName
	$termStore = $taxonomySession.TermStores[$mmsProxyName]
	$userName = $env:USERNAME
	$admins = $termStore.TermStoreAdministrators | Where-Object {$_.PrincipalName -contains $userName}
	if($admins -eq $null){
		$termStore.AddTermStoreAdministrator($env:USERNAME)
		$termStore.CommitAll()
	}
	else{
		Write-Host "The user $userName is already admin of the term store." -F Yellow
	}
}