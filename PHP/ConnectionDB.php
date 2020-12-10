<?php 
 include "consts.php";
class ClsRetryLogic {
    private $oConnection;
    private $bClose = true;
    private $UserName = US_CONN_USER_NAME;
    private $Password = US_CONN_USER_PWD;
    function HazUnaConexionConReintentos($sConnection)
    {
     $retryIntervalSeconds = 10;
     $calculation;
     $returnBool=false;
    
     for ($tries=1; $tries <= US_CONN_TIMES_TO_RETRY; $tries++)
     {
       try
         { 
          $starttime = microtime(true);
          if($tries>1) 
          {
            SaveResults("Retry - Waiting time: " . $retryIntervalSeconds);
            sleep($retryIntervalSeconds);
            $calculation = $retryIntervalSeconds * 1.5;
            $retryIntervalSeconds = $calculation;            
          }
          SaveResults("Connecting to Database");
         $this->oConnection = new pdo($sConnection, $this->get_username(), $this->get_password(),array(
            PDO::ATTR_TIMEOUT => 1,PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION ));
            SaveResults("Connected to Database"); 

         $returnBool = true;
         $endtime = microtime(true);
         $timediff = $endtime - $starttime;
         SaveResults("Connection time : ".secondsToTime($timediff).'. Ms: '.($timediff));
         break;
         }
       catch(Exception $e)
       {
        SaveResults("Error connecting to .. " . $e->getMessage());
       } 
    }  
    return $returnBool;
}

  function get_Connection() {
    return $this->oConnection;
  }

  function set_close($bCloseIndicator)
  {
      $this->bClose=$bCloseIndicator;
  }

  function get_close()
  {
      return $this->bClose;
  }

  function CloseConnection()
  {
    if( $this->get_close() == TRUE)
    {
     SaveResults("Closing connection.") ;
     $this->oConnection=null;
    } 
  }

  function set_username($UserNameParam)
  {
      $this->UserName=$UserNameParam;
  }

  function get_username()
  {
      return $this->UserName;
  }

  function set_password($PasswordParam)
  {
      $this->Password=$PasswordParam;
  }

  function get_password()
  {
      return $this->Password;
  }

}
?>