$DatabaseServer = "xxxxx.database.windows.net"
$Database = "xxxxxx"
$Username = "xxxxxx"
$Password = "xxxxxx" 
$Pooling = $true
$NumberExecutions =10
$File = "E:\TSQL.SQL"
$OutputLog = "C:\TEMP\LOG.txt"

cls

  $sw = [diagnostics.stopwatch]::StartNew()
  for ($i=0; $i -lt $NumberExecutions; $i++)
  {
   try
    {
     
     $connectionString = "Server=tcp:$DatabaseServer,1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$Username;Password=$Password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30"

         if( $Pooling -eq $true )
            {
              $connectionString = $connectionString + ";Pooling=True"
            } 
         else
            {
              $connectionString = $connectionString + ";Pooling=False"
            }

     $ExistFile= Test-Path $File

         if($ExistFile -eq 1)
          {
            $query = @(Get-Content $File) 
          }
          else
          {
            $query = @("SELECT 1")
          }
       
       $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
       $connection.StatisticsEnabled = 1 
       $command = New-Object -TypeName System.Data.SqlClient.SqlCommand
       $command.CommandTimeout = 60
       $command.Connection=$connection
                  
     for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) 
     {
       $start = get-date
       $connection.Open()
         $command.CommandText = $query[$iQuery]
         $command.ExecuteNonQuery() | Out-Null 
       $connection.Close()
       $end = get-date
       $data = $connection.RetrieveStatistics()
       write-Output "-------------------------" | Out-File $OutputLog -Append -width 300 
       write-Output ("Query                 :  " + $query[$iQuery]) | Out-File $OutputLog -Append -width 300
       write-Output ("Iteration             :  " +$i) | Out-File $OutputLog -Append  -Width 300
       write-Output ("Time required (ms)    :  " +(New-TimeSpan -Start $start -End $end).TotalMilliseconds) | Out-File $OutputLog -Append  -Width 300
       write-Output ("NetworkServerTime (ms):  " +$data.NetworkServerTime) | Out-File $OutputLog -Append  -Width 300
       write-Output ("Execution Time (ms)   :  " +$data.ExecutionTime) | Out-File $OutputLog -Append  -Width 300
       write-Output ("Connection Time       :  " +$data.ConnectionTime) | Out-File $OutputLog -Append -Width 300
       write-Output ("ServerRoundTrips      :  " +$data.ServerRoundtrips) | Out-File $OutputLog -Append -Width 300
       write-Output ("BuffersReceived       :  " +$data.BuffersReceived) | Out-File $OutputLog -Append -Width 300
       write-Output ("SelectRows            :  " +$data.SelectRows) | Out-File $OutputLog -Append -Width 300
       write-Output ("SelectCount           :  " +$data.SelectCount) | Out-File $OutputLog -Append -Width 300
       write-Output ("BytesSent             :  " +$data.BytesSent) | Out-File $OutputLog -Append -Width 300
       write-Output ("BytesReceived         :  " +$data.BytesReceived) | Out-File $OutputLog -Append -Width 300
       write-Output "-------------------------" | Out-File $OutputLog -Append  -Width 300
      }
     }
    catch
   {
    Write-Output -ForegroundColor DarkYellow "You're WRONG" | Out-File $OutputLog -Append -Width 300
    Write-Output -ForegroundColor Magenta $Error[0].Exception | Out-File $OutputLog -Append -Width 300
   }
   
}
write-Output ("Time spent (ms) Procces :  " +$sw.elapsed) | Out-File $OutputLog -Append -Width 300
write-Output ("Review: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/provider-statistics-for-sql-server") | Out-File $OutputLog -Append -Width 300
