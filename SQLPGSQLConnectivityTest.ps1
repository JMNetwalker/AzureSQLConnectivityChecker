
$DatabaseServer = "servername.postgres.database.azure.com"
$Database = "databasename"
$Username = "username@servername"
$Password = "password" 
$Pooling = $true
$NumberExecutions =10
$File = "C:\CR\TSQL.SQL"

cls

  $sw = [diagnostics.stopwatch]::StartNew()
  for ($i=0; $i -lt $NumberExecutions; $i++)
  {
   try
    {
     
     $connectionString = "DSN=PostgreSQL30;Uid=$Username;Pwd=$Password"

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
       
       $connection = New-Object System.Data.Odbc.OdbcConnection($connectionString)
       $command = New-Object $connection.CreateCommand()
       $command.CommandTimeout = 60
       $command.Connection=$connection
                  
     for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) 
     {
       $start = get-date
       $connection.Open()
       $end = get-date
       
       $command.CommandText = $query[$iQuery]
       $command.ExecuteNonQuery() | Out-Null 

       $command.CommandText = "SELECT coalesce(usename,'NoUser'), coalesce(datname,'NoDB'), coalesce(query,'NoQuery'), coalesce(Wait_event,'---') FROM pg_stat_activity L"
         write-Output "-------------------------"  | Out-File c:\cr\my.log -Append -width 300
         write-Output ("Query                 :  " + $query[$iQuery] ) | Out-File c:\cr\my.log -Append -width 300
         write-Output ("Iteration             :  " + $i ) | Out-File c:\cr\my.log -Append -width 300
         write-Output ("Connection time (ms)  :  " + (New-TimeSpan -Start $start -End $end).TotalMilliseconds ) | Out-File c:\cr\my.log -Append -width 300
         write-Output ("Profiling             : USER/DBNAME/QUERY/WAITSTAT") | Out-File c:\cr\my.log -Append -width 300
         $reader = $command.ExecuteReader() 
         if ($reader.HasRows)
         {
            while ($reader.Read() -eq $true)
            {
               write-Output ($reader.GetString(0).PadRight(22,' ') + ": " + $reader.GetString(1) + " " + $reader.GetString(2) + " " + $reader.GetString(3) ) | Out-File c:\cr\my.log -Append -width 300
            }
         }
            else
            {
              write-Output "No rows found." | Out-File c:\cr\my.log -Append -width 300
            }
        write-Output "-------------------------"   | Out-File c:\cr\my.log -Append -width 300   
        $reader.Close()
        $connection.Close()
      }
     }
    catch
   {
    Write-Output -ForegroundColor DarkYellow "You're WRONG" | Out-File c:\cr\my.log -Append -width 300
    Write-Output -ForegroundColor Magenta $Error[0].Exception | Out-File c:\cr\my.log -Append -width 300
   }
   
}
write-Output ("Time spent (ms) Procces :  " +$sw.elapsed) | Out-File c:\cr\my.log -Append -Width 300