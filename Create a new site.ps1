Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
$DatabaseServerName = "DB SERVER NAME"
$WebAppName = "WEBAPP URL"
$User = "domain\username"
$Template = "STS#0"

$DatabaseName = "DBNAME"
$SiteUrl = "SITE URL"
$SiteTitle = ""

New-SPSite -Name $SiteTitle -ContentDatabase $DatabaseName -url $SiteUrl -OwnerAlias $User -Template $Template



<#
Mount-SPContentDatabase $DatabaseName  -DatabaseServer $DatabaseServerName -WebApplication $WebAppName

Get-SPContentDatabase -ConnectAsUnattachedDatabase  -DatabaseName <DatabaseName> -DatabaseServer <DatabaseServer>

Restore-SPSite URLSITE -Path 'C:\PATH\FILENAME.bak' –Confirm:$false
#>