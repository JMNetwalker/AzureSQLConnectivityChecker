[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data") 

$DatabaseServer = "xxxxx.mysql.database.azure.com"
$Database = "xxxx"
$Username = "xxxxx@xxxxx"
$Password = "xxxxx" 
$Pooling = $true
$NumberExecutions =10
$File = "E:\TSQL.SQL"

cls

  $sw = [diagnostics.stopwatch]::StartNew()
  for ($i=0; $i -lt $NumberExecutions; $i++)
  {
   try
    {
     
     $connectionString = "Server=$DatabaseServer;database=$Database;Uid=$Username;Pwd=$Password"

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
       
       $connection = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection($connectionString)
       $command = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
       ##$reader = New-Object -TypeName MySql.Data.MySql.MySqlDataReader
       $command.CommandTimeout = 60
       $command.Connection=$connection
                  
     for ($iQuery=0; $iQuery -lt $query.Count; $iQuery++) 
     {
       $start = get-date
       $connection.Open()
       $end = get-date
       
       $command.CommandText = "SET profiling=1"
       $command.ExecuteNonQuery() | Out-Null
       $command.CommandText = $query[$iQuery]
       $command.ExecuteNonQuery() | Out-Null 

       $command.CommandText = "SHOW PROFILE ALL"
         write-Output "-------------------------"  | Out-File e:\my.log -Append -width 300
         write-Output ("Query                 :  " + $query[$iQuery] ) | Out-File e:\my.log -Append -width 300
         write-Output ("Iteration             :  " + $i ) | Out-File e:\my.log -Append -width 300
         write-Output ("Connection time (ms)  :  " + (New-TimeSpan -Start $start -End $end).TotalMilliseconds ) | Out-File e:\my.log -Append -width 300
         write-Output ("Profiling             : DURATION CPU USER CPU SYSTEM") | Out-File e:\my.log -Append -width 300
         $reader = $command.ExecuteReader() 
         if ($reader.HasRows)
         {
            while ($reader.Read() -eq $true)
            {
               write-Output ($reader.GetString(0).PadRight(22,' ') + ": " + $reader.GetString(1) + " " + $reader.GetString(2) + " " + $reader.GetString(3) ) | Out-File e:\my.log -Append -width 300
            }
         }
            else
            {
              write-Output "No rows found." | Out-File e:\my.log -Append -width 300
            }
        write-Output "-------------------------"   | Out-File e:\my.log -Append -width 300   
        $reader.Close()
        $connection.Close()
      }
     }
    catch
   {
    Write-Output -ForegroundColor DarkYellow "You're WRONG" | Out-File e:\my.log -Append -width 300
    Write-Output -ForegroundColor Magenta $Error[0].Exception | Out-File e:\my.log -Append -width 300
   }
   
}
write-Output ("Time spent (ms) Procces :  " +$sw.elapsed) | Out-File e:\my.log -Append -Width 300
write-Output ("Review: https://dev.mysql.com/doc/refman/5.5/en/profiling-table.html") | Out-File e:\my.log -Append -Width 300
