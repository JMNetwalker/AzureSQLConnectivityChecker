## Copyright (c) Microsoft Corporation.
#Licensed under the MIT license.

#Azure Connection and Execution Time Spent

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#------------------------------------------------------------------------------
#About this PowerShell Script
#
#We usually have service requests that our customers using different drivers need to know the connection latency, execution time spent or validate the connection.
#For this reason, I developed this small PowerShell script  (based on initiative of AzureSQLConnectivityChecker in multiple languages) which will basically connect to the database using 2 drivers/providers and test this.
#This PowerShell Script has been designed to run in a cloudshell environment.
#-------------------------------------------------------------------------------

Param($DatabaseServer = "",
      $Database = "",
      $Username = "",
      $password = "" ,
      $NumberExecutions ="",
      $InputFile = "",
      $LogFile="",
      $Driver = "")

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

       logMsg("Review the ports workload") (1) -SaveFile $false 
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
           logMsg("Ports Count : " +$Portcheck + " (" + $PortSQL + ") 11xx: (" + $Port11s + ") Others:(" + $PortOther+ ")") (1)       
           logMsg("Ports Status: " ) (1)
               for ($i=1; $i -lt $StateDesc.Count; $i++)
               {
                logMsg( "---->" + $StateDesc[$i] + " (" + $StateTmp[$i].ToString() + ")") (1)
               }
       logMsg("Reviewed the ports workload") (1) -SaveFile $false 
     }
    catch
    {
       logMsg("Imposible to review the ports workload - Error: " + $Error[0].Exception) (2)
    }
  } 


#-------------------------------
#Delete the file
#-------------------------------
Function DeleteFile{ 
  Param( [Parameter(Mandatory)]$FileName ) 
  try
   {
    logMsg("Checking if the file..." + $FileName + " exists.") -SaveFile $false 
    if( FileExist($FileName))
    {
     logMsg("Removing the file..." + $FileName) -SaveFile $false   
     $Null = Remove-Item -Path $FileName -Force 
     logMsg("Removed the file..." + $FileName) -SaveFile $false  
    }
    return $true 
   }
  catch
  {
   logMsg("Remove the file..." + $FileName + " - " + $Error[0].Exception) (2) 
   return $false
  }
 }

#-----------------------------------------------------------
# Identify if the value is empty or not
#-----------------------------------------------------------

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

#-------------------------------
#File Exists
#-------------------------------
Function FileExist{ 
  Param( [Parameter(Mandatory)]$FileName ) 
  try
   {
    $return=$false
    $FileExists = Test-Path $FileName
    if($FileExists -eq $True)
    {
     $return=$true
    }
    return $return
   }
  catch
  {
   return $false
  }
 }


#--------------------------------
#Obtain the DNS details resolution.
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
    return $sAddress
    break;
 }
  catch
 {
  return ""
 }
}


#----------------------------------------------------------------
#Function to connect to the database using a retry-logic
#----------------------------------------------------------------

Function GiveMeConnectionSource($DriverParam)
{ 
  $lNumRetries=10
  for ($i=1; $i -le $lNumRetries; $i++)
  {
   try
    {

      logMsg( "---------------------------------------------------------------------------------------------------------------")      
      logMsg( "Connecting to the database: " + $DatabaseServer + " - DB: " + $Database + "...Attempt #" + $i + " of " + $lNumRetries.ToString() + " - IP:" + $(CheckDns($DatabaseServer)))      
      
      if($DriverParam.Trim().ToUpper() -eq "SQLCLIENT")
      {
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection 
        $SQLConnection.ConnectionString = "data source=tcp:"+$DatabaseServer +",1433"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Initial Catalog="+$Database
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Connection Timeout=30"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";User ID="+ $Username
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Password="+ $password
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Application Name=Test SQLCLIENT Connection" 
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Persist Security Info=False"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";ConnectRetryInterval=3"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";ConnectRetryInterval=10"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Max Pool Size=100"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Min Pool Size=1"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";MultipleActiveResultSets=False"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Pooling=True"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Encrypt=True"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";TrustServerCertificate=False"
        $SQLConnection.StatisticsEnabled = 1
      } 

      if($DriverParam.Trim().ToUpper() -eq "ODBC")
      {
        $SQLConnection = New-Object System.Data.Odbc.OdbcConnection
        $SQLConnection.ConnectionString = "Driver={ODBC Driver 17 for SQL Server}"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Server=tcp:"+$DatabaseServer +",1433"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Database="+$Database
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Connection Timeout=30"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";UID="+ $Username
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";PWD="+ $password
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Application Name=Test ODBC Connection" 
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Persist Security Info=False"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";SQL_ATTR_CONNECTION_POOLING = SQL_CP_ONE_PER_HENV"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";ConnectRetryInterval=3"
        $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";ConnectRetryInterval=10"

      } 

      $start = get-date
        $SQLConnection.Open()
      $end = get-date

      if($DriverParam.Trim().ToUpper() -eq "SQLCLIENT")
      {
        $sAdditionalInformation = " - ID:" + $SQLConnection.ClientConnectionId.ToString() + " -- HostName: " + $SQLConnection.WorkstationId + " Server Version:" + $SQLConnection.ServerVersion
      }

      if($DriverParam.Trim().ToUpper() -eq "ODBC")
      {
        $sAdditionalInformation = " - Driver:" + $SQLConnection.Driver.ToString() + " -- HostName: " + $SQLConnection.WorkstationId + " Server Version:" + $SQLConnection.ServerVersion
      }

      $LatencyAndOthers.ConnectionsDone_Number_Success = $LatencyAndOthers.ConnectionsDone_Number_Success+1
      $LatencyAndOthers.ConnectionsDone_MS = $LatencyAndOthers.ConnectionsDone_MS+(New-TimeSpan -Start $start -End $end).TotalMilliseconds

      logMsg("Connected to the database in (ms):" +(New-TimeSpan -Start $start -End $end).TotalMilliseconds + " " + $sAdditionalInformation ) (3)
      logMsg("Total Connections Failed : " + $LatencyAndOthers.ConnectionsDone_Number_Failed.ToString())
      logMsg("Total Connections Success: " + $LatencyAndOthers.ConnectionsDone_Number_Success.ToString())
      logMsg("Total Connections ms     : " + ($LatencyAndOthers.ConnectionsDone_MS / $LatencyAndOthers.ConnectionsDone_Number_Success).ToString())

      $Null = Get-TcpConnectionInfo("1433","0") #TCP ports opened
      return $SQLConnection
      break;
    }
  catch
   {
    $LatencyAndOthers.ConnectionsDone_Number_Failed = $LatencyAndOthers.ConnectionsDone_Number_Failed +1
    logMsg("Not able to connect - Retrying the connection..." + $Error[0].Exception.ErrorRecord + "-" + $Error[0].Exception.ToString().Replace("\t"," ").Replace("\n"," ").Replace("\r"," ").Replace("\r\n","").Trim()) (2)
    $WaitTime = (5*($i+1))
    logMsg("Waiting for next retry in " + $WaitTime.ToString() + " seconds ..") -SaveFile $false 
    Start-Sleep -s $WaitTime
    if($Driver -eq "SQLCLIENT") { [System.Data.SqlClient.SqlConnection]::ClearAllPools() }
   }
  }
}

#--------------------------------
#Verify if the value is able to convert to integer
#--------------------------------

Function IsInteger([string]$vInteger)
{
    Try
    {
        $null = [convert]::ToInt32($vInteger)
        return $True
    }
    Catch
    {
        return $False
    }
}  

#--------------------------------
#Log the operations
#--------------------------------
function logMsg
{
    Param
    (
         [Parameter(Mandatory=$false, Position=0)]
         [string] $msg,
         [Parameter(Mandatory=$false, Position=1)]
         [int] $Color,
         [Parameter(Mandatory=$false, Position=2)]
         [boolean] $Show=$true,
         [Parameter(Mandatory=$false, Position=3)]
         [boolean] $ShowDate=$true,
         [Parameter(Mandatory=$false, Position=4)]
         [boolean] $SaveFile=$true,
         [Parameter(Mandatory=$false, Position=5)]
         [boolean] $NewLine=$true 
 
    )
  try
   {
    If(TestEmpty($msg))
    {
     $msg = " "
    }

    if($ShowDate -eq $true)
    {
      $Fecha = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    }
    $msg = $Fecha + " " + $msg
    If($SaveFile -eq $true)
    {
      Write-Output $msg | Out-File -FilePath $LogFile -Append
    }
    $Colores="White"

    If($Color -eq 1 )
     {
      $Colores ="Cyan"
     }
    If($Color -eq 3 )
     {
      $Colores ="Yellow"
     }
    If($Color -eq 4 )
     {
      $Colores ="Green"
     }
    If($Color -eq 5 )
     {
      $Colores ="Magenta"
     }

     if($Color -eq 2 -And $Show -eq $true)
      {
         if($NewLine)
         {
           Write-Host -ForegroundColor White -BackgroundColor Red $msg 
         }
         else
         {
          Write-Host -ForegroundColor White -BackgroundColor Red $msg -NoNewline
         }
      } 
     else 
      {
       if($Show -eq $true)
       {
        if($NewLine)
         {
           Write-Host -ForegroundColor $Colores $msg 
         }
        else
         {
           Write-Host -ForegroundColor $Colores $msg -NoNewline
         }  
       }
      } 


   }
  catch
  {
    Write-Host $msg 
  }
}

Class LatencyAndOthers #Class to manage the connection latency
{
 [long]$ConnectionsDone_MS = 0
 [long]$ConnectionsDone_Number_Success = 0
 [long]$ConnectionsDone_Number_Failed = 0
 [long]$ExecutionsDone_MS = 0
 [long]$ExecutionsDone_Number_Success = 0
 [long]$ExecutionsDone_Number_Failed = 0
}

$LatencyAndOthers = [LatencyAndOthers]::new()
[System.Collections.ArrayList]$IPArrayConnection = @()
[System.Collections.ArrayList]$Query = @()
[System.Collections.ArrayList]$CommandArray = @()
[System.Collections.ArrayList]$QueryMetrics = @()

cls

if (TestEmpty($DatabaseServer)) 
    { $DatabaseServer = read-host -Prompt "Please enter a Server Name" }

if (TestEmpty($DatabaseServer)) 
    { 
     logMsg ("Server Name is empty. Closing the application.") 
     exit;
    }

if (TestEmpty($Database))  
    { $Database = read-host -Prompt "Please enter a Database Name"  }

if (TestEmpty($Database)) 
     { 
      logMsg ("DatabaseName Name is empty. Closing the application.") 
      exit;
     }

if (TestEmpty($Username))  
     { $Username = read-host -Prompt "Please enter a User Name"   }

if (TestEmpty($Username)) 
     { 
      logMsg ("User Name is empty. Closing the application.") 
       exit;
      }

if (TestEmpty($Password))  
    {  
    $Password = read-host -Prompt "Please enter a password" -MaskInput
    }

if (TestEmpty($Password)) 
     { 
      logMsg ("Password is empty. Closing the application.") 
      exit;
     }

 if (TestEmpty($NumberExecutions)) 
   {
    $NumberExecutions = read-host -Prompt "Please enter the number of test to run (1-2000) - Leave this field empty and press enter for default value 10."
   }

if (TestEmpty($NumberExecutions)) 
     { 
       $NumberExecutions="10"
     }

 if( -not (IsInteger([string]$NumberExecutions)))
   {
    logMsg("Please, specify a correct number of process to run, the value is not integer") (2)
    exit;
   }


 $IntegerNumberExecutions = [int]::Parse($NumberExecutions)

 if($integerNumberExecutions -lt 1 -or $integerNumberExecutions -gt 2000)
   {
    logMsg("Please, specify a correct number of process to run, it is a value between 1 and 2000") (2)
    exit;
   }

if(TestEmpty($InputFile))
  { 
   $query = @("SELECT 1")
   logMsg ("Using the default one - SELECT 1 -- File has not been selected") 
  }
  else
  {
   If( FileExist($InputFile) ) 
   {
    $query = @(Get-Content $InputFile) 
   }
   else
   {
     $query = @("SELECT 1")
     logMsg ("Using the default one - SELECT 1 - File doesn't exist") 
   }
  }

if(TestEmpty($LogFile))
  { 
   $LogFile = $HOME + "/defaulttest.Log"
   logMsg ("Using the default one for log file") 
  }

if(TestEmpty($Driver))
{
    logMsg ("Driver has not been selected") (2)
    exit;
}

if($Driver.ToString().ToUpper() -ne "SQLCLIENT" -and $Driver.ToString().ToUpper() -ne "ODBC")
{
    logMsg ("Driver has not been selected or it is wrong " + $Driver) (2)
    exit;
}

  $Null = DeleteFile($LogFile)
  logMsg("Driver chosen: " + $Driver) 

  foreach($Tmp in $Query) ##Create the same number of command that queries that we need.
  {
   $QueryMetricTmp = [LatencyAndOthers]::new()
   $Null = $QueryMetrics.add($QueryMetricTmp)
   if($Driver.Trim().ToUpper() -eq "SQLCLIENT")
   {
    $command = New-Object -TypeName System.Data.SqlClient.SqlCommand
    $command.CommandTimeout = 60
    $command.Prepare()
    $command.CommandText = $Tmp
    $Null = $CommandArray.Add($command)
   }
   if($Driver.Trim().ToUpper() -eq "ODBC")
   {
    $command = New-Object -TypeName System.Data.Odbc.OdbcCommand
    $command.CommandTimeout = 60
    $command.CommandText = $Tmp
    $Null = $CommandArray.Add($command)
   }

  }

  $sw = [diagnostics.stopwatch]::StartNew() ##Take the time.

  for ($i=1; $i -le $IntegerNumberExecutions; $i++) ##For every number of process open a new connection and close it at the end.
  {
   try
    {

      $Null = $IPArrayConnection.Add($(GiveMeConnectionSource $Driver)) #Connecting to the database.
      if($IPArrayConnection[$i-1] -eq $null)
      { 
          LogMsg("Not able to connect. Closing the application...") (2) 
          exit;
      }
     
     for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) #for Every query run it. 
     {
       $CommandArray[$iQuery].Connection = $IPArrayConnection[$i-1] 
       Try
       {
         $lDiff=0
         LogMsg( "-------------------------------------------------------------------------------------" )
         LogMsg( "Query                 : " + $query[$iQuery]) 
         LogMsg( "Iteration             : " + $i + " Query " + ($iQuery+1).ToString() + " / " + $query.Count) 
         $start = get-date
           $Null = $CommandArray[$iQuery].ExecuteNonQuery()
         $end = get-date
         $lDiff=(New-TimeSpan -Start $start -End $end).TotalMilliseconds
         $QueryMetrics[$iQuery].ExecutionsDone_Number_Success = $QueryMetrics[$iQuery].ExecutionsDone_Number_Success+1
         $QueryMetrics[$iQuery].ExecutionsDone_MS = $QueryMetrics[$iQuery].ExecutionsDone_MS+$lDiff
         
         $LatencyAndOthers.ExecutionsDone_Number_Success = $LatencyAndOthers.ExecutionsDone_Number_Success+1
         $LatencyAndOthers.ExecutionsDone_MS = $LatencyAndOthers.ExecutionsDone_MS+$lDiff
         LogMsg( "Time required (ms)    : " + $lDiff.ToString()) 
       }
       catch
       {
         $LatencyAndOthers.ExecutionsDone_Number_Failed = $LatencyAndOthers.ExecutionsDone_Number_Failed+1
         $QueryMetrics[$iQuery].ExecutionsDone_Number_Failed = $QueryMetrics[$iQuery].ExecutionsDone_Number_Failed+1
         LogMsg( "Error: " + $Error[0].Exception) (2)
       }

       if($Driver.Trim().ToUpper() -eq "SQLCLIENT")
       {
         $data = $IPArrayConnection[$i-1].RetrieveStatistics()
       }
       
       
       
       if($Driver.Trim().ToUpper() -eq "SQLCLIENT")
       {
        LogMsg( "NetworkServerTime (ms): " +$data["NetworkServerTime"]) 
        LogMsg( "Execution Time (ms)   : " +$data["ExecutionTime"]) 
        LogMsg( "Connection Time       : " +$data["ConnectionTime"]) 
        LogMsg( "ServerRoundTrips      : " +$data["ServerRoundtrips"])
        LogMsg( "BuffersReceived       : " +$data["BuffersReceived"]) 
        LogMsg( "SelectRows            : " +$data["SelectRows"]) 
        LogMsg( "SelectCount           : " +$data["SelectCount"]) 
        LogMsg( "BytesSent             : " +$data["BytesSent"]) 
        LogMsg( "BytesReceived         : " +$data["BytesReceived"]) 
       } 

        logMsg( "Query Commands Failed : " + $QueryMetrics[$iQuery].ExecutionsDone_Number_Failed.ToString())
        logMsg( "Query Commands Success: " + $QueryMetrics[$iQuery].ExecutionsDone_Number_Success.ToString())
        logMsg( "Query Commands ms     : " + ($QueryMetrics[$iQuery].ExecutionsDone_MS / $QueryMetrics[$iQuery].ExecutionsDone_Number_Success).ToString())

        logMsg( "Total Commands Failed : " + $LatencyAndOthers.ExecutionsDone_Number_Failed.ToString())
        logMsg( "Total Commands Success: " + $LatencyAndOthers.ExecutionsDone_Number_Success.ToString())
        logMsg( "TotalCommands ms      : " + ($LatencyAndOthers.ExecutionsDone_MS / $LatencyAndOthers.ExecutionsDone_Number_Success).ToString())

       LogMsg( "--------------------------------------------------------------------------------------" ) -SaveFile $false
      }
      $IPArrayConnection[$i-1].Close() ##Close the connection.
     }
    catch
   {
    LogMsg( "Error: " + $Error[0].Exception) (2)
   }
   
}

logMsg("-------------------------------------- SUMMARY -----------------------------------------------------------------")
logMsg("Total Connections Failed :" + $LatencyAndOthers.ConnectionsDone_Number_Failed.ToString())
logMsg("Total Connections Success:" + $LatencyAndOthers.ConnectionsDone_Number_Success.ToString())
logMsg("Total Connections Avg ms :" + ($LatencyAndOthers.ConnectionsDone_MS / $LatencyAndOthers.ConnectionsDone_Number_Success).ToString())
LogMsg("Total Number Executions  :" + $IntegerNumberExecutions) 
LogMsg("Total Number Queries     :" + $query.Count) 
LogMsg("Total Number Process     :" + ($IntegerNumberExecutions*$query.Count)) 
logMsg("Total Commands Failed    :" + $LatencyAndOthers.ExecutionsDone_Number_Failed.ToString())
logMsg("Total Commands Success   :" + $LatencyAndOthers.ExecutionsDone_Number_Success.ToString())
logMsg("Total Commands ms        :" + ($LatencyAndOthers.ExecutionsDone_MS / $LatencyAndOthers.ExecutionsDone_Number_Success).ToString())
$i=0
LogMsg("------------------- Queries Summary" + $Tmp)
foreach($Tmp in $Query) ##Create the same number of command that queries that we need.
{
 LogMsg("Query #               :" + $Tmp)
 logMsg("Total Commands Failed :" + $QueryMetrics[$i].ExecutionsDone_Number_Failed.ToString())
 logMsg("Total Commands Success:" + $QueryMetrics[$i].ExecutionsDone_Number_Success.ToString())
 logMsg("Total Commands ms     :" + ($QueryMetrics[$i].ExecutionsDone_MS / $QueryMetrics[$i].ExecutionsDone_Number_Success).ToString())
 $i=$i+1
}


LogMsg( "Review: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/provider-statistics-for-sql-server") 
logMsg("-------------------------------------- SUMMARY -----------------------------------------------------------------")
Remove-Variable password
Remove-Variable username
