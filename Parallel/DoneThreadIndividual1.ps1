$DatabaseServer = "servername.database.windows.net"
$Database = "databasename"
$Username = "username"
$Password = "password" 
$Pooling = $true
$NumberExecutions =1000
$FolderV = "C:\Test\"

function GiveMeSeparator
{
Param([Parameter(Mandatory=$true)]
      [System.String]$Text,
      [Parameter(Mandatory=$true)]
      [System.String]$Separator)
  try
   {
    [hashtable]$return=@{}
    $Pos = $Text.IndexOf($Separator)
    $return.Text= $Text.substring(0, $Pos) 
    $return.Remaining = $Text.substring( $Pos+1 ) 
    return $Return
   }
  catch
  {
    $return.Text= $Text
    $return.Remaining = ""
    return $Return
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

Function GiveMeConnectionSource()
{ 
  for ($i=1; $i -lt 10; $i++)
  {
   try
    {
      logMsg( "Connecting to the database...Attempt #" + $i) (1)

      $SQLConnection = New-Object System.Data.SqlClient.SqlConnection 
      $SQLConnection.ConnectionString = "Server="+$DatabaseServer+";Database="+$Database+";User ID="+$username+";Password="+$password+";Connection Timeout=15" 
      if( $Pooling -eq $true )
        {
          $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Pooling=True"
        } 
      else
        {
          $SQLConnection.ConnectionString = $SQLConnection.ConnectionString + ";Pooling=False"
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



cls


  $sw = [diagnostics.stopwatch]::StartNew()


  logMsg("Creating the folder " + $FolderV) (1)
   $result = CreateFolder($FolderV) 
   If( $result -eq $false)
    { 
     logMsg("Was not possible to create the folder") (2)
     exit;
    }
logMsg("Created the folder " + $FolderV) (1)

$LogFile = $FolderV + "Results" + $args[0] + ".Log"    #Logging the operations.

$query = @("SELECT 1")


  for ($i=0; $i -lt $NumberExecutions; $i++)
  {
   try
    {

      $SQLConnectionSource = GiveMeConnectionSource #Connecting to the database.
      if($SQLConnectionSource -eq $null)
      { 
        logMsg("It is not possible to connect to the database") (2)
      }
      else
      {
       
       $SQLConnectionSource.StatisticsEnabled = 1 
       $command = New-Object -TypeName System.Data.SqlClient.SqlCommand
       $command.CommandTimeout = 60
       $command.Connection=$SQLConnectionSource
                  
         for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) 
         {
           $start = get-date
             $command.CommandText = $query[$iQuery]
             $command.ExecuteNonQuery() | Out-Null 
           $end = get-date
           $data = $SQLConnectionSource.RetrieveStatistics()
           logMsg("-------------------------")
           logMsg("Query                 :  " + $query[$iQuery]) 
           logMsg("Iteration             :  " +$i) 
           logMsg("Time required (ms)    :  " +(New-TimeSpan -Start $start -End $end).TotalMilliseconds) 
           logMsg("NetworkServerTime (ms):  " +$data.NetworkServerTime) 
           logMsg("Execution Time (ms)   :  " +$data.ExecutionTime) 
           logMsg("Connection Time       :  " +$data.ConnectionTime) 
           logMsg("ServerRoundTrips      :  " +$data.ServerRoundtrips) 
           logMsg("-------------------------")
          }
          $SQLConnectionSource.Close()

      }
    }
    catch
   {
    logMsg( "You're WRONG") (2)
    logMsg($Error[0].Exception) (2)
   }
   
}
logMsg("Time spent (ms) Procces :  " +$sw.elapsed) (2)
logMsg("Review: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/provider-statistics-for-sql-server") (2)