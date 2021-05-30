Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#FIXED VALUES
$DatabaseServerName = ""
$WebAppName = "WEBAPP SITE URL"
$User = "domain\username"
$Template = "STS#0"

$IsRootSite = $false

if($IsRootSite)
{
    #VARIABLES
    $DatabaseName = "DEV_Content_TEMPLATE_RootSite"
    $SiteUrl = "rootsite URL"
    $SiteTitle = "Root Site"

    #Create content database for the root site
    New-SPContentDatabase -Name $DatabaseName -DatabaseServer $DatabaseServerName -WebApplication $WebAppName -MaxSiteCount 100 -WarningSiteCount 80

    #Create a new rootsite
    New-SPSite -Name $SiteTitle -ContentDatabase $DatabaseName -url $SiteUrl -OwnerAlias $User -Template $Template
}

if(-Not($IsRootSite))
{
    #VARIABLES
    $DatabaseName = "DEV_Content_TEMPLATE_SubSite"
    $SiteUrl = "SubSite URL"
    $SiteTitle = "Sub-Site"

    #Create content database for the subsite
    #New-SPContentDatabase -Name $DatabaseName -DatabaseServer $DatabaseServerName -WebApplication $WebAppName -MaxSiteCount 100 -WarningSiteCount 80

    #Create a new subsite
    New-SPSite -Name $SiteTitle -ContentDatabase $DatabaseName -url $SiteUrl -OwnerAlias $User -Template $Template
}