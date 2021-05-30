Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
 
#Managed Metadata Service Application Name
$MMSAppName="Managed Metadata Service Application"
#New location of Content Type Hub
$ContentTypeHub ="CONTENT TYPE HUB SITE URL"
#set content type hub powershell
Set-SPMetadataServiceApplication -Identity $MMSAppName -HubURI $ContentTypeHub
Write-host "Content Type location updated!"