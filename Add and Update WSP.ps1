Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
#ADD WSP
#Add-SPSolution c:\PATH\FILENAME.wsp

#INSTALL WSP
#Install-SPSolution –Identity FILENAME.wsp –WebApplication "SITE URL" –GACDeployment -Local 

#UPDATE WSP
#Update-SPSolution –Identity FILENAME.wsp –LiteralPath “C:\PATH\FILENAME.wsp” –GACDeployment