# Import the Active Directory module for the Get-ADComputer CmdLet 
Import-Module ActiveDirectory 
Import-Module PSTerminalServices
# Query Active Directory for computers running a Server operating system 
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} 

# Loop through the list to query each server for login sessions 
#$Servers.Count
ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
 
    # When running interactively, uncomment the Write-Host line below to show which server is being queried 
    #Write-Host "Querying $ServerName" 
    $pingResult= Test-Connection -ComputerName $ServerName -Count 1 -ErrorAction silentlycontinue
    
    if($pingResult -ne $null)
    {
	    # Run the qwinsta.exe and parse the output 
	    $queryResults = $sessions = Get-TSSession -ComputerName $ServerName
	     if($queryResults.Count -gt 0)
	     {
		$SessionList = $SessionList + "`n" + $ServerName  + "`n" 
	     }
	   # Pull the session information from each instance 
	    ForEach ($queryResult in $queryResults) { 
	        $RDPUser = $queryResult.UserName
	        $sessionType = $queryResult.WindowsStationName
	        
	        # We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number 
	        If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL)) {  
	            # When running interactively, uncomment the Write-Host line below to show the output to screen 
	            #Write-Host $ServerName logged in by $RDPUser on $sessionType 
	            $SessionList = $SessionList + "`t" + $RDPUser + "`n"
	        } 
	    } 
    }
    else 
    {
	$OfflineServers = $OfflineServers + "`n" + $ServerName
    }
} 

    $SessionList
$OfflineServers
