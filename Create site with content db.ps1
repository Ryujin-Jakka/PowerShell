Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop

#Variabes
#The Web Application URL
$WebAppUrl =  "" 
#The default managed path is "sites", meanwhile you can create a new Managed Path as you prefer
$ManagedPath ="sites" 
#Type "Y" for Wildcard inclusion, "N" for Explicit inclusion
$wildcard = "Y" 
#The Site Collection Name
$SiteCollectionName = "" 
#The Site Collection URL
$SiteCollectionURL = $WebAppUrl +"/"+ $ManagedPath + "/"+ $SiteCollectionName 
#The Site Collection Title
$SiteCollectionTitle = ""
#The site template code (Default is Team Site), to get all Templates name run Get-SPWebTemplate 
$Template = "STS#0"
#The primary Site Collection Administrator
$OwnerAlias = "domain\user name"
#The default site language, type 1025 for Arabic in case you have installed the Arabic Language Pack
$Language ="1033" 
#The content database name must be unique so it will depend on the site collection name
$ContentDB = "WSS_Content_" + $SiteCollectionName


#Create a Site Collection with its own Content Database
function CreateSiteCollectionAndContentDB()
{
    Try{
        #Get the SQL Server Instance
        $DBServer = (Get-SPContentDatabase | ?{$_.Type -eq "Content Database"})[0].server
        #Create A content Databse
        Write-Host "Create A new Content Database" -ForegroundColor Green
        $result = New-SPContentDatabase $ContentDB -DatabaseServer $DBServer -WebApplication $WebAppUrl
        
		if($result -ne $null) 
        {
           Write-Host "The Content Database " $ContentDB " has been created successfully" -ForegroundColor Cyan
           #Lockdown
           Write-Host "Lock Down the Content Database" -ForegroundColor Green
           Set-SPContentDatabase -Identity $ContentDB -MaxSiteCount 1 -WarningSiteCount 0
           Write-Host "The Content Database " $ContentDB " has been locked successfully" -ForegroundColor Cyan
           # Create Managed path
           $MPath = Get-SPManagedPath -WebApplication $WebAppUrl -Identity $ManagedPath -ErrorAction SilentlyContinue
           if ($MPath -ne $null)
             {
               Write-Host "Managed path $ManagedPath already exists."
             }
           else
             {
               Write-Host "Creating managed path $ManagedPath ..."
               if($wildcard -eq "Y")
               {
                 New-SPManagedPath –RelativeURL $ManagedPath -WebApplication $WebAppUrl 
               }
               else
               {
                 New-SPManagedPath –RelativeURL $ManagedPath -WebApplication $WebAppUrl -Explicit
               }
                Write-Host "Managed path $ManagedPath created sucessfully" -foregroundcolor Green
             }
           #create Site Collection
           Write-Host "Create a new Site Collection" $SiteCollectionName " in"  $ContentDB -ForegroundColor Green
           if($wildcard -eq "Y")
             {
               $SiteCollectionURL = $WebAppUrl +"/"+ $ManagedPath + "/"+ $SiteCollectionName
             }
           else
             {
               $SiteCollectionURL = $WebAppUrl +"/"+ $ManagedPath 
             }
        
		    $result = New-SPSite $SiteCollectionURL -Name $SiteCollectionTitle -OwnerAlias $OwnerAlias -Language $Language -Template $Template
            if($result -ne $null) 
               {
                 Write-Host "The Site Collection " $SiteCollectionName " has been created successfully" -ForegroundColor Cyan
                 #browse New Site colection 
                 START $SiteCollectionURL
               }
            else
               {
                Write-Host "Error: The Site Collection is not created" -ForegroundColor Red
                return
               }
        }
        else
        {
           Write-Host "Error: The Content DataBase is not Created" -ForegroundColor Red
           return
        }
      }
    Catch
      {
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
      }
}
CreateSiteCollectionAndContentDB