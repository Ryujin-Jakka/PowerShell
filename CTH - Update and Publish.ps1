Param(
    [string] $ctSiteUrl="CTH SITE URL",
    [string] $group="" #Content type group name
)
if(!($ctSiteUrl))
{
    Write-Host "Error: Site parameter missing." -ForegroundColor Red
    Write-Host "Usage: Update-ContentTypeHub $ctSiteUrl $group"
    return
}
if(!($group))
{
    Write-Host "Error: Group parameter missing." -ForegroundColor Red
    Write-Host "Usage: Update-ContentTypeHub $ctSiteUrl $group"
    return
}
#Set the execution policy 
Set-ExecutionPolicy Unrestricted 
#Add the required SP snapins 
Add-PSSnapIn Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue | Out-Null 
function Publish-ContentTypeHub {
    param
    (
        [parameter(mandatory=$true)][string]$CTHUrl,
        [parameter(mandatory=$true)][string]$Group
    )
 
    $site = Get-SPSite $CTHUrl
    if(!($site -eq $null))
    {
        $contentTypePublisher = New-Object Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher ($site)
        $site.RootWeb.ContentTypes | ? {$_.Group -match $Group} | % {
            $contentTypePublisher.Publish($_)
            write-host "Content type" $_.Name "has been republished" -foregroundcolor Green
        }
    }
}

#Updates the Content Type subscribers for each web application 
function Update-ContentHub([string]$url) 
{ 
    #Get the Timer job info     
    $job = Get-SPTimerJob -WebApplication $url | ?{ $_.Name -like "MetadataSubscriberTimerJob"} 
     
    #check that the job is not null 
    if ($job -ne $null)  
    {   
        #run the timer job 
        $job | Start-SPTimerJob 
        
        #run the admin action 
        Start-SPAdminJob -ErrorAction SilentlyContinue
    }
} 
#force publish of the content types
Publish-ContentTypeHub $ctSiteUrl $group
	write-host
	write-host "Waiting for 10 seconds for job to finish..."
	Start-Sleep -s 10
	write-host
#get the web applications and update the content type hub subscribers for each web application 
Get-SPWebApplication | ForEach-Object { Write-Host "Updating Metadata for site:" $_.Url; Update-ContentHub -url $_.Url } 