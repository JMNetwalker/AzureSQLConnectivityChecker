
<?php 
 include "ConnectionDB.php";
 include "consts.php";
 SaveResults("Starting ODBC Test Console - PHP..") ;
 $conn = Array(US_CONN_TIMES_TO_EXECUTE);
 $UserName = US_CONN_USER_NAME;
 $Password = US_CONN_USER_PWD;

 arguments($argv, $UserName, $Password);

  for ($i = 0; $i <= US_CONN_TIMES_TO_EXECUTE ; $i++)
  {
    $starttime = microtime(true);
    try
    { 
      if( US_CONN_TIMES_CHECK_PORT == TRUE)
      {
        bCheckTCPPort(US_CONN_TIMES_SERVER_NAME,array(US_CONN_TIMES_PORT));
      }  
     
     $conn[$i] = new ClsRetryLogic();
     $conn[$i]->set_close(US_CONN_TIMES_TO_CLOSE);
     $conn[$i]->set_username($UserName);
     $conn[$i]->set_password($Password);
     if( $conn[$i]->HazUnaConexionConReintentos(US_CONN_DSN_NAME) == TRUE)
     {
       for ($tries=1; $tries <= US_TSQL_TIMES_TO_EXECUTE; $tries++)
        {
         if(US_TSQL_EXECUTE_SELECT_1)
         {
          bGiveMeResults(US_TSQL_TEXT_TO_EXECUTE, $conn[$i]);
         }  
         if(US_TSQL_EXECUTE_SELECT_NVARCHAR)
         {
          bSelectNVarchar(US_TSQL_TEXT_TO_SELECT_NVARCHAR_EXECUTE, $conn[$i]);
         }  
        }    
     }
      $conn[$i]->CloseConnection();
      if(US_CONN_TIMES_CHECK_STATUS_PORT==TRUE)
      {
        $output = get_listening_ports();
      }   

    }
   catch(Exception $e)
     {
        SaveResults("Error connecting to .. " . $e->getMessage());
     }
    $endtime = microtime(true);
    $timediff = $endtime - $starttime;
    SaveResults(" Connection loop # ".$i.' Time Spent: '.secondsToTime($timediff).'. Ms: '.($timediff));
 }

function secondsToTime($s)
{
    $h = floor($s / 3600);
    $s -= $h * 3600;
    $m = floor($s / 60);
    $s -= $m * 60;
    return $h.':'.sprintf('%02d', $m).':'.sprintf('%02d', $s);
}

function bGiveMeResults($tsql,$conn)
{
try
{
    $starttime = microtime(true);
    $getResults= $conn->get_Connection()->query($tsql);
    SaveResults("Reading data from TSQL: " . $tsql);
      if ($getResults == FALSE)
       echo (sqlsrv_errors());
      while ($row = $getResults->fetch(PDO::FETCH_ASSOC)) 
      {
        echo ($row['X'] . PHP_EOL);
      }
      $getResults=null;
      $endtime = microtime(true);
      $timediff = $endtime - $starttime;
      SaveResults("Time Select 1: ".secondsToTime($timediff).'.--'.($timediff));
  }
   catch(Exception $e)
  {
    SaveResults("Error running the query .. " . $e->getMessage());
  }
}

function bCheckTCPPort($host,$ports)
{
  
  foreach ($ports as $port)
  {
      $connection = @fsockopen($host, $port);
  
      if (is_resource($connection))
      {
        SaveResults( "Server: " . $host . ':' . $port . ' ' . '(' . getservbyport($port, 'tcp') . ') is open.');
  
          fclose($connection);
      }
  
      else
      {
        SaveResults( "Server: " . $host . ':' . $port . ' is not responding.' );
      }
  }
}


function bSelectNVarchar($tsql,$conn)
{
try
{
    $starttime = microtime(true);
    $random=random_int(0,48000);
    $stmt=$conn->get_Connection()->prepare($tsql);
    $stmt->setAttribute(PDO::SQLSRV_ATTR_QUERY_TIMEOUT, US_TSQL_EXECUTE_TIMEOUT);  
    $stmt->bindValue(1, "Example " . $random, PDO::PARAM_STR);
    $stmt->execute();
    SaveResults("Reading data from TSQL: " . $tsql);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) 
      {
        echo ($row['X'] . PHP_EOL);
      }
    $stmt=null;
    $endtime = microtime(true);
    $timediff = $endtime - $starttime;
    SaveResults("Time nVarchar: ".secondsToTime($timediff).'.--'.($timediff));
  }
   catch(Exception $e)
  {
    SaveResults("Error Running the query .. " . $e->getMessage());
  }
}

function get_listening_ports()
{
    $output  = array();
    $options = ( strtolower( trim( @PHP_OS ) ) === 'linux' ) ? '-atn' : '-an';

    ob_start();
    system( 'netstat '.$options );

    foreach( explode( "\n", ob_get_clean() ) as $line )
    {
        $line  = trim( preg_replace( '/\s\s+/', ' ', $line ) );
        $parts = explode( ' ', $line );

        if( count( $parts ) > 3 )
        {
            $state   = strtolower( array_pop( $parts ) );
            $foreign = array_pop( $parts );
            $local   = array_pop( $parts );

            if( !empty( $state ) && !empty( $local ) )
            {
                $final = explode( ':', $local );
                $port  = array_pop( $final );

                if( is_numeric( $port ) )
                {
                   SaveResults("Status: ".$state.' Port:'.$port." Line: ".$line) ;
                   $output[ $state ][ $port ] = $port;
                }
            }
        }
    }
    return $output;
}

function arguments($argv, &$UserName, &$Password) {
  $_ARG = array();
  foreach ($argv as $arg) {
    if (preg_match('/--([^=]+)=(.*)/',$arg,$reg)) {
      $_ARG[$reg[1]] = $reg[2];
      echo $_ARG[$reg[1]].$reg[1];
      if(strtolower($reg[1])=="password")
       {  
         $Password=$_ARG[$reg[1]];
       }
       if(strtolower($reg[1])=="username")
       {  
         $UserName=$_ARG[$reg[1]];
       }
    } elseif(preg_match('/-([a-zA-Z0-9])/',$arg,$reg)) 
       {
          $_ARG[$reg[1]] = 'true';
      }
   }
}

?>