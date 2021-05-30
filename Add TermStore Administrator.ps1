Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
$taxonomySession = Get-SPTaxonomySession -Site "SITEURL"
$termStore = $taxonomySession.TermStores["Managed Metadata Service Application Proxy"]
$termStore.AddTermStoreAdministrator("USERNAME")
$termStore.CommitAll()