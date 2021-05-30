Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
Backup-SPSite "SITE_URL" –Path C:\PATH\FILENAME.bak -UseSqlSnapshot