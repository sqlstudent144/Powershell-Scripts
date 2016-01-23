@@ -0,0 +1,54 @@
﻿#Error handling
$ErrorActionPreference = "continue";
Trap {
  $err = $_.Exception
  while ( $err.InnerException )
    {
    $err = $err.InnerException
    write-error $err.Message
    };
  }


#Load-SMOType (12)

#Driver variables, will become params
$MaxConnections = 3
$Server= "(local)\sql2014cs" ;

#Set Initial collections and objects    
$SqlInstance = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
$DbConnections = @();
$dbs = $SqlInstance.Databases | Where-Object {$_.IsSystemObject -eq 0} 

#Build DB connection array
for($i=0;$i -le $MaxConnections-1;$i++){
  $randdb = Get-Random -Minimum 1 -Maximum $dbs.Count
  $DbConnections += $dbs[$randdb].Name
}

#$DbConnections

<#
Add-Type -AssemblyName "Microsoft.SqlServer.Smo,Version=$(12).0.0.0,Culture=neutral,PublicKeyToken=89845dcd8080cc91"
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$SqlConn = New-Object Microsoft.SqlServer.Management.Smo.Server("$Server")
$SqlConn.Databases['master'].ExecuteNonQuery("WAITFOR DELAY '00:05:00'")
#>

#Loop through DB Connection array, create script block for establishing SMO connection/query
#Start-Job for each script block
foreach ($DBName in $DbConnections ) {
#$DBNameStr = $DBName.Name
 $cmdstr =@"
`Add-Type -AssemblyName "Microsoft.SqlServer.Smo,Version=$(12).0.0.0,Culture=neutral,PublicKeyToken=89845dcd8080cc91"
`[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
`$SqlConn = New-Object Microsoft.SqlServer.Management.Smo.Server ("$Server")
`$SqlConn.Databases['$DBName'].ExecuteNonQuery("WAITFOR DELAY '00:00:30'")
"@

$cmdstr

$cmd = [ScriptBlock]::Create($cmdstr)
Start-Job -ScriptBlock $cmd
}
