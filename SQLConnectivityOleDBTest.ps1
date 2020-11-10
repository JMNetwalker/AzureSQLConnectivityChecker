#----------------------------------------------------------------
# Application: Connectivity Checker V.1
# Propose: Verify the connectivity for check intermittent connections
#----------------------------------------------------------------

#----------------------------------------------------------------
#Parameters 
#----------------------------------------------------------------
param($server = "", #ServerName parameter to connect 
      $user = "", #UserName parameter  to connect
      $password = "", #Password Parameter  to connect
      $Db = "", #DBName Parameter  to connect
      $LogFile = "C:\ConnReport\Connectivity.Log", #Folder Parameter to save the log file
      $Pooling =1, #Use pooling
      $NumberExecutions = 100, #Number of operations to perform, (Remember that 100 operations * delay per execution)
      $Provider = "MSOLEDBSQL", #Provider
      $DelayBetweenExecution=1, #Delay between executions 
      $PortCX = "1433", #Port to check
      $DetailPort="0" , #Detailed or not the port list
      $ScanPort ="1") #Scan de port

#----------------------------------------------------------------
#Connection OleDB
#----------------------------------------------------------------

Function GiveMeConnectionSourceOleDB()
{ 
  for ($i=1; $i -le 2; $i++)
  {
   try
    {
      logMsg( "Connecting to the database...Attempt #" + $i) (1)
      $SQLConnection = New-Object System.Data.OleDb.OleDbConnection
      $SQLConnection.ConnectionString = "Provider="+$Provider+";Server=tcp:"+$server+","+$PortCX+";Database="+$Db+";UID="+$user+";PWD="+$password+";Timeout=60" 
      If($Pooling -eq 1) 
       {
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";OLE DB Services =-1"
       }
      else
       {
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";OLE DB Services =-8"
       }
      $SQLConnection.Open()
      logMsg("Connected to the database...") (1) 
      return $SQLConnection
      break;
    }
  catch
   {
    logMsg("Not able to connect - Retrying the connection..." + $Error[0].Exception) (2)
    Start-Sleep -s 5
   }
  }
}

#--------------------------------
#Log the operations
#--------------------------------
function logMsg
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $msg,
         [Parameter(Mandatory=$false, Position=1)]
         [int] $Color
    )
  try
   {
    $Fecha = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    $msg = $Fecha + " " + $msg
    Write-Output $msg | Out-File -FilePath $LogFile -Append
    $Colores="White"
    $BackGround = 
    If($Color -eq 1 )
     {
      $Colores ="Cyan"
     }
    If($Color -eq 3 )
     {
      $Colores ="Yellow"
     }

     if($Color -eq 2)
      {
        Write-Host -ForegroundColor White -BackgroundColor Red $msg 
      } 
     else 
      {
        Write-Host -ForegroundColor $Colores $msg 
      } 
   }
  catch
  {
    Write-Host $msg 
  }
}

#-------------------------------
#Delete the log file 
#-------------------------------
Function DeleteFile{ 
  Param( [Parameter(Mandatory)]$FileName ) 
  try
   {
    $FileExists = Test-Path $FileNAme
    if($FileExists -eq $True)
    {
     Remove-Item -Path $FileName -Force 
    }
    return $true 
   }
  catch
  {
   return $false
  }
 }

 #--------------------------------------------------------------
#Create a folder 
#--------------------------------------------------------------
Function CreateFolder
{ 
  Param( [Parameter(Mandatory)]$Folder ) 
  try
   {
    $FileExists = Test-Path $Folder
    if($FileExists -eq $False)
    {
     $result = New-Item $Folder -type directory 
     if($result -eq $null)
     {
      logMsg("Imposible to create the folder " + $Folder) (2)
      return $false
     }
    }
    return $true
   }
  catch
  {
   return $false
  }
 }

#--------------------------------
#The Folder Include "\" or not???
#--------------------------------

Function GiveMeFolderName{ 
  Param( 
      [Parameter(Mandatory=$true)]
      [System.String]$outfile ) 
  try
   {
    $Pos = $outfile.LastIndexofAny("\")
    If($Pos -ne 0)
     { 
      $sFolder = $outfile.Substring(0,$Pos)
     } 
    else
     {
      $sFolder = $outfile
     }
    return $sFolder
    }
  catch
  {
   return $outfile
  }
 }

#--------------------------------
#Obtain the TCP Connection Info
#--------------------------------

function Get-TcpConnectionInfo($Portcheck,$CXWantDetailedPort)
    {
    Try
     {
       $StateDesc = [System.Collections.ArrayList]@()
       $StateTmp  = [System.Collections.ArrayList]@()
       $PortSQL = 0
       $Port11s = 0
       $PortOther = 0
       $PortTmp = 0
       $bFound = $false

       logMsg("Review the ports workload") (1)
       $TcpConnections = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpConnections()
           ForEach($TcpConnection in $TcpConnections)
           {
            if($CXWantDetailedPort -eq 1 ) { logMsg("LocalEndPoint:" + $TcpConnection.LocalEndPoint + " - RemoteEndPoint:" + $TcpConnection.RemoteEndPoint + " - State:" + $TcpConnection.State) (1) }

            #Review the port opened

               $PortTmp = [int]$TcpConnection.RemoteEndPoint.Port
               $PortOther++
               If($PortTmp -eq $Portcheck) {$PortSQL++}
               elseif( $PortTmp -ge 11000 -And $PortTmp -le 12000 ) {$Port11s++}

            #Review the state

               $bFound=$false

               for ($i=1; $i -lt $StateDesc.Count; $i++)
               {
                if($StateDesc[$i] -eq $TcpConnection.State) 
                  { 
                   $StateTmp[$i]++
                   $bFound=$true
                   break
                  }
               }

               If($bFound -eq $false) 
               {
                $StateDesc.Add($TcpConnection.State) | Out-Null
                $StateTmp.Add(1) | Out-Null
               }

           }
           $PortOther=$PortOther-($PortSQL+$Port11S) #Calculate the total.
       logMsg("Summary Ports: (" +$Portcheck + ") " + $PortSQL + " 11xx:" + $Port11s + " Others:" + $PortOther) (1)       
               for ($i=1; $i -lt $StateDesc.Count; $i++)
               {
                logMsg("Summary Status:" + $StateDesc[$i] + " Total of " + $StateTmp[$i]) (1)
               }
       logMsg("Reviewed the ports workload") (1)
     }
    catch
    {
       logMsg("Imposible to review the ports workload - Error: " + $Error[0].Exception) (2)
    }
  } 

#--------------------------------
#Validate Param
#--------------------------------

function TestEmpty($s)
{
if ([string]::IsNullOrWhitespace($s))
  {
    return $true;
  }
else
  {
    return $false;
  }
}

#--------------------------------
#Check DNS
#--------------------------------
function CheckDns($sReviewServer)
{
try
 {
    $IpAddress = [System.Net.Dns]::GetHostAddresses($sReviewServer)
    foreach ($Address in $IpAddress)
    {
        $sAddress = $sAddress + $Address.IpAddressToString + " ";
    }
    logMsg("ServerName:" + $sReviewServer + " has the following IP:" + $sAddress) (1)
 }
  catch
 {
  logMsg("Imposible to resolve the name - Error: " + $Error[0].Exception) (2)
 }
}

#-----------------
#Scan de port
#------------------

function ScanPort($sReviewServer, $sPort)
{
 Try
 {
  $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
  $TCPClient.Connect($sReviewServer,$sPort)
 } 
 Catch  
 {
    logMsg("Imposible to check the port - Error: " + $Error[0].Exception) (2) 
 } 
 Finally  
 {
  $TCPClient.Close()
  $TCPClient.Dispose()
 } 
}

##Let's run the process

cls

if (TestEmpty($server)) { $server = read-host -Prompt "Please enter a Server Name" }
if (TestEmpty($user))  { $user = read-host -Prompt "Please enter a User Name"   }
if (TestEmpty($password))  
    {  
    $passwordSecure = read-host -Prompt "Please enter a password"  -assecurestring  
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordSecure))
    }
if (TestEmpty($Db))  { $Db = read-host -Prompt "Please enter a Database Name"  }
if (TestEmpty($LogFile)) {  $LogFile = read-host -Prompt "Please enter a Destination File Log - Example c:\log\log.log" }
if (TestEmpty($Provider))  { $Provider = read-host -Prompt "Please enter the provider to use - SQLOLEDB or MSOLEDBSQL"  }
if (TestEmpty($Pooling))  { $Pooling = read-host -Prompt "Please enter the pooling to use (1=Use it/0=Don't use it"  }
if (TestEmpty($NumberExecutions))  { $NumberExecutions = read-host -Prompt "Please enter the number of executions"  }
if (TestEmpty($DelayBetweenExecution))  { $DelayBetweenExecution = read-host -Prompt "Please enter the number of seconds of delay among executions"  }
if (TestEmpty($PortCX))  { $PortCX = read-host -Prompt "Please enter the number of your SQL server is listening"  }
if (TestEmpty($DetailPort))  { $DetailPort = read-host -Prompt "Please enter if you want to have a detailed list of the ports (1=Yes,0=No)"  }
if (TestEmpty($ScanPort))  { $ScanPort = read-host -Prompt "Please enter if you want to scan the port of your SQL Server is listening"  }

$swGlobal = [diagnostics.stopwatch]::StartNew()     
$Folder = GiveMeFolderName($LogFile)

logMsg("Creating the folder " + $Folder) (1)
   $result = CreateFolder($Folder) #Creating the folder that we are going to have the results, log and zip.
   If( $result -eq $false)
    { 
     logMsg("Was not possible to create the folder") (2)
     exit;
    }
logMsg("Created the folder " + $Folder) (1)

logMsg("Deleting Log") (1)
   $result = DeleteFile($LogFile) #Delete Log file
logMsg("Deleted Log") (1)



  $query = @("SELECT 1")

  
  for ($i=1; $i -le $NumberExecutions; $i++)
  {
   try
    {
     logMsg("-------------------------") (1)
     $sw = [diagnostics.stopwatch]::StartNew()     
     $result=""
     Get-TcpConnectionInfo $PortCX $DetailPort
     CheckDns($server)

     $connection = GiveMeConnectionSourceOleDB

     if (TestEmpty($connection)) 
     {
      logMsg("Retry-Logic was not working - It is not possible to continue with the program." ) (2)
      exit;
     }

     $command = New-Object -TypeName System.Data.OleDb.OleDbCommand
     $command.CommandTimeout = 60
     $command.Connection=$connection
     
     if($ScanPort -eq "1") { ScanPort $server $PortCX }
                  
     for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) 
     {
       $start = get-date
       logMsg("------------------------- Executing the query ------------------- ")
       logMsg("Query                 :  " + $query[$iQuery])
       logMsg("Iteration             :  " + $i + " of " + $NumberExecutions + " Delay " + $DelayBetweenExecution )
       
         $command.CommandText = $query[$iQuery]
         Try
         {
           $result = $command.ExecuteNonQuery() 
         }
         catch
         {
          logMsg("Error Executing the Query:" + $Error[0].Exception) (2)
         }
       $end = get-date

       logMsg("Query Execution       :  " + $result) 
       logMsg("Time required (ms)    :  " + (New-TimeSpan -Start $start -End $end).TotalMilliseconds)
       Start-Sleep -s $DelayBetweenExecution
      }
     $connection.Close()
     logMsg("Time spent (ms) Proccess:  " +$sw.elapsed) (1)
     }
    catch
   {
    logMsg("Error:" + $Error[0].Exception) (2)
   }
   logMsg("Time spent (ms) Proccess:  (Global) " +$swGlobal.elapsed) (1)
}