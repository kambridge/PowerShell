<# Daily checks for all servers listed in the string. Returns the following information:
-Review IIS Pools (Function IISPools)
-Timer Job Status
-Review installed features
-Disk Use (C: & D:)
-Event Logs (Critical, Errors and Application recycle events)
-Site Quota Web Applications (Function SiteQuota)
#>
<# SERVER NAMES#>
 $ServerNames = "<servername>", "<servername>","<servername>"

Param([string]$ELogStartDate = $("Specify a start date for Event Log report (m/dd/yyyy)"));

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

#Retrieve Application Pool information
function IISPools() {
    $IISPoolsFilePath = "D:\DailyChecks\iispools_" + $date + ".txt"
    Write-Host "IIS Pools Function Started"
    #Import WebAdministration
    if((Get-Module WebAdministration -ErrorAction SilentlyContinue) -eq $null){
       Import-Module WebAdministration
    }
        
    $ServerNames = $ServerNames
    $ServerNames = $PRODServerNames
    
    foreach($ServerName in $ServerNames){
        $TitleOG = $ServerName + " | State Values: 1-starting; 2-started; 3-stopping; 4-stopped" 
        $IISView = Get-WmiObject -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy -Impersonation Impersonate -Class IIsApplicationPoolSetting -ComputerName $ServerName 
        $IISOutput = $IISView | Select PATH,Name,WAMUserName,AppPoolState | Format-Table -Wrap  | Out-File -append $IISPoolsFilePath
        #$cmdview = $IISOutput | write-output
            foreach ($pool in $IISView){
               #write-output $pool
                if ($pool.AppPoolState -gt 2){
                    Write-Host $pool.PATH, $pool.Name, $pool.WAMUserName, $pool.AppPoolState -foregroundcolor "magenta"
                }else{
                    Write-Host $pool.PATH, $pool.Name, $pool.WAMUserName, $pool.AppPoolState
                }
            }
    }
    Write-Host "IIS Pools Function Ended"
}

function SiteQuota(){

    Write-Host "Site Quota Function Started"
    $SQWebApps = "<url>","<url>","<url>"
    
    $SQWebApps = $SQWebApps
        
    foreach ($SQWebApp in $SQWebApps){
        $Rootweb = [Microsoft.Sharepoint.Administration.SPWebApplication]::Lookup($SQWebApp);
        #$Webapp = $Rootweb.WebApplication;
        #Loops through each site collection within the Web app
        foreach ($Site in $Rootweb.Sites){         
            #Is Quota greater than 0
            if ($Site.Quota.StorageMaximumLevel -gt 0) {
                $MaxStorage = $Site.Quota.StorageMaximumLevel /1MB
            }else {
                $MaxStorage="0"
            }           
            #Quota greater than 0 
            if ($Site.Usage.Storage -gt 0) {
                $StorageUsed = $Site.Usage.Storage /1MB
            }            
            #Quota greater than 0 and Max Storage greater than 0
            if ($StorageUsed -gt 0 -and $MaxStorage -gt 0){
                $SiteQuotaUsed = $StorageUsed/$MaxStorage* 100
            } 
            else{
                $SiteQuotaUsed = "0"
            }
            $Web = $Site.Rootweb;               
            #Create Hash 
            $hash = @{
                "Site Web Application" = $Site.WebApplication;
                "Site Url" = $Site.Url
                "Content Database" = $Site.ContentDatabase
                "Quota Limit (MB)" = $MaxStorage
                "Total Storage Used (MB)" = $StorageUsed
                "Total Storage Used (GB)" = $StorageUsed/1024
                "Site Quota Percentage Used" = $SiteQuotaUsed
                
            }
            
            $StorageUsedGB = $StorageUsed/1000
            if (($StorageUsed -gt 25000)-and ($StorageUsed -lt 75000)){
                Write-Host $Site.Url, $StorageUsedGB -foregroundcolor "cyan"
            }
            elseif (($StorageUsed -gt 75000)-and ($StorageUsed -lt 100000)){
                Write-Host $Site.Url, $StorageUsedGB -foregroundcolor "yellow"
            }
            elseif ($StorageUsed -gt 100000){
                Write-Host $Site.Url, $StorageUsedGB -foregroundcolor "magenta"
            }
            # Convert the hash to an object and output to the pipeline
            New-Object PSObject -Property $hash
            $Site.Dispose()      
        }
        Write-Host "Site Quota Function Ended"
    }
}

#Failed Timer Jobs

function FailedTimerJobs {
    $f = [Microsoft.SharePoint.Administration.SPFarm]::Local
    Write-Host "Failed Timer Job Function Started"
    $days = "3"
    #All Job History (today) Path
    $path = "D:\DailyChecks\alljobs_" + $date + ".csv"
    #$path = "D:\DailyChecks\failedjobs_" + $date + ".csv"
    $f = get-spfarm
    $ts = $f.TimerService
    #All Job History (today)
    $jobs = $ts.JobHistoryEntries | ?{$_.StartTime -gt ((get-date).AddDays(-1))} 
    #$jobs = $ts.JobHistoryEntries | ?{$_.Status -eq "Failed" -and $_.StartTime -gt ((get-date).AddDays(-$days))} 
    
    $items = New-Object psobject
    $items | Add-Member -MemberType NoteProperty -Name "Title" -value ""
    $items | Add-Member -MemberType NoteProperty -Name "Server" -value ""
    $items | Add-Member -MemberType NoteProperty -Name "Status" -value ""
    $items | Add-Member -MemberType NoteProperty -Name "StartTime" -value ""
    $items | Add-Member -MemberType NoteProperty -Name "EndTime" -value ""
    $items | Add-Member -MemberType NoteProperty -Name "Duration" -value ""
    $a = $null
    $a = @()

    foreach($i in $jobs){
        $b = $items | Select-Object *; 
        $b.Title = $i.JobDefinitionTitle;
        $b.Server = $i.ServerName;
        $b.Status = $i.Status;
        $b.StartTime = $i.StartTime;
        $b.EndTime = $i.EndTime;
        $b.Duration = ($i.EndTime - $i.StartTime);
        $a += $b;
    if ($i.Status -eq "Failed"){
        write-host $b.Title, $b.Server, $b.Status, $b.StartTime, $b.EndTime, $b.Duration -foregroundcolor "magenta"
    }
    }
    $a | Where-Object {$_} | Export-Csv -Delimiter "," -Path $path -notype 
    Write-Host "Failed Timer Job Function Complete" 
}

function GetSPSolution {
    Write-Host "Get SP Solution Function Started"
    $farm=[Microsoft.SharePoint.Administration.SPFarm]::Local
    foreach ($solution in $farm.Solutions){
        if ($solution.Deployed){
            $hash = @{
                "SP Solution" = $solution.DisplayName
                "Status" = "Deployed"
            }
            # Convert the hash to an object and output to the pipeline
            New-Object PSObject -Property $hash
            Write-Host $solution.DisplayName, "Deployed" -foregroundcolor "darkgreen"            
        }else{
            $hash = @{
                "SP Solution" = $solution.DisplayName
                "Status" = "Not Deployed"
            }
            # Convert the hash to an object and output to the pipeline
            New-Object PSObject -Property $hash 
            Write-Host $solution.DisplayName, "Not Deployed" -foregroundcolor "magenta"                       
        }                  
    }
    Write-Host "Get SP Solution Function Completed"
}
function DiskUsage {
    $ServerNames = "<servername>","<servername>","<servername>"
    $ServerNames = $ServerNames
    $DiskUsageFilePath = "D:\DailyChecks\diskusage_" + $date + ".csv"
    
    foreach ($ServerName in $ServerNames){
        $diskusage = Get-WMIObject Win32_LogicalDisk -filter "DriveType=3" -computer ($ServerName) 
        $diskusage | Select SystemName,DeviceID,VolumeName,@{Name="size(GB)";Expression={"{0:N1}" -f($_.size/1gb)}},@{Name="freespace GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}} | Out-File -append $DiskUsageFilePath
        
	foreach ($du in $diskusage){
            $dusize = $du.size/1073741824
            $dufree = $du.freespace/1073741824
            $dupercent = $dufree/$dusize
            if($dupercent -lt .25){
                write-host $du.SystemName, $du.DeviceID, $du.VolumeName, $dusize, $dufree -foreground "magenta"
            }else{
                write-host $du.SystemName, $du.DeviceID, $du.VolumeName, $dusize, $dufree 
            }            
        } 										
    }
}

function Eventlogs {
    $ServerNames = "<servername>","<servername>","<servername>"
    $ServerNames = $ServerNames
   
    $eldays = "2"

    foreach ($ServerName in $ServerNames){
        Write-Host "Get Event Logs for: " $ServerName
        $Events = Get-WinEvent -FilterHashtable @{logname='application','system';level=1,2;StartTime=((get-date).AddDays(-$eldays));EndTime=$EventLogdate} -ComputerName $ServerName | write-output
        foreach ($i in $Events){
            $hash = @{
            "Time Created" = $i.TimeCreated
            "Server" = $i.MachineName
            "Provider Name" = $i.ProviderName
            "Level" = $i.LevelDisplayName
            "Id" = $i.Id
            "Message" = $i.Message
            }
            #Write-Host
            if ($i.LevelDisplayName -eq "Critical"){
                Write-Host $i.TimeCreated, $i.MachineName, $i.ProviderName, $i.LevelDisplayName, $i.Id, $i.Message -foregroundcolor "magenta"
            }
            # Convert the hash to an object and output to the pipeline
            New-Object PSObject -Property $hash 
               
        }
    }
}

function SPServices {
    $ServerNames = "<servername>","<servername>","<servername>"
    $ServerNames = $ServerNames

    $SPServicesFilePath = "D:\DailyChecks\spservices_" + $date + ".txt"
    Write-Host "SP Services Function Starting"

    foreach ($ServerName in $ServerNames){

        $services = Get-SPServiceInstance -Server $ServerName
        $services | Sort TypeName | Format-Table -Wrap Id,TypeName,Server,Status | Out-File -append $SPServicesFilePath 
        foreach ($service in $services){
            if($service.status -eq "Disabled"){
                Write-Host $service.Server, $service.Id, $service.TypeName, $service.Status -foregroundcolor "DarkMagenta"
            }
            if($service.status -eq "Online"){
                Write-Host $service.Server, $service.Id, $service.TypeName, $service.Status -foregroundcolor "DarkGreen"
            }
        }        
    }
    Write-Host "SP Services Function Ended"
}

function SPContentDatabase {
    
    $ContentDBs = Get-SPDatabase

    foreach ($ContentDB in $ContentDBs){

        $contentdatabases = Get-SPContentDatabase -Identity $ContentDB -ErrorAction SilentlyContinue
        #$contentdatabases | Format-Table Name, @{Label="Size in GB"; Expression={$_.disksizerequired/1073741824}}, @{Label="Web Application"; Expression={$_.WebApplication}} | Out-File -append $SPDBPath
        foreach ($cd in $contentdatabases){
            $cdsize = $cd.disksizerequired/1073741824
            #$outfile =  $cd.webapplication + " | "+ $cd.Name + " | "+ $cdsize + "GB" | Out-File -append $SPDBPath
            
            $hash = @{
                "Web Application" = $cd.webapplication
                "Content Database" = $cd.Name
                "DB Size" = $cdsize
            }
            New-Object PSObject -Property $hash
            #$Site.Dispose() 
            if ($cd.disksizerequired/1073741824 -lt 100){
                Write-Host $cd.webapplication, $cd.Name, $cdsize , "GB" -foregroundcolor " cyan"
            }
            if (($cd.disksizerequired/1073741824 -gt 100) -and ($cd.disksizerequired/1073741824 -lt 300)){
                Write-Host $cd.webapplication, $cd.Name, $cdsize, "GB" -foregroundcolor "yellow"
            }
            if ($cd.disksizerequired/1073741824 -gt 300){
                Write-Host $cd.webapplication, $cd.Name, $cdsize, "GB" -foregroundcolor "magenta"
            }
        }
    }
}

#VAR / PATHS

#Current Date
$date = Get-Date -UFormat "%m_%d_%Y"
Write-Host "Current date" $date

#Site Quota Path
$sqpath = "D:\DailyChecks\sitecolquota_" + $date + ".csv"

#SP Solution Status Path
$spsolutionpath = "D:\DailyChecks\spsolutionstatus_" + $date + ".csv"

#Event Log Path
$EventLogdate = Get-Date -UFormat "%m/%d/%Y"
$EventLogpath = "D:\DailyChecks\eventlogs_" + $date + ".csv"

#Content Database Path
$SPDBPath = "D:\DailyChecks\SPdatabases_" + $date + ".csv"

#FUNCTIONS

#Execute IISPools
#IISPools

#Execute Site Quota
#SiteQuota | Export-Csv -NoTypeInformation -Path $sqpath
    
#Execute failed timer jobs
#FailedTimerJobs

#Execute SP Solution Status
#GetSPSolution | Export-Csv -NoTypeInformation -Path $spsolutionpath

#Disk Usage
#DiskUsage

#Execute Event Log
#Eventlogs | Export-Csv -NoTypeInformation -Path $EventLogpath

#Execute SPServices 
#SPServices

#Execute SP Content Databases
#SPContentDatabase | Export-Csv -NoTypeInformation -Path $SPDBPath
