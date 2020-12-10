<?php
if(!defined('US_TSQL_TEXT_TO_EXECUTE')) define( 'US_TSQL_TEXT_TO_EXECUTE', "SELECT 1 as X");
if(!defined('US_TSQL_TIMES_TO_EXECUTE')) define( 'US_TSQL_TIMES_TO_EXECUTE',5);

if(!defined('US_CONN_TIMES_TO_EXECUTE')) define( 'US_CONN_TIMES_TO_EXECUTE', 1000);
if(!defined('US_CONN_TIMES_TO_RETRY')) define( 'US_CONN_TIMES_TO_RETRY', 5);
if(!defined('US_CONN_TIMES_TO_CLOSE')) define( 'US_CONN_TIMES_TO_CLOSE', FALSE);
if(!defined('US_CONN_TIMES_PROTOCOL')) define( 'US_CONN_TIMES_PROTOCOL', "TCP");
if(!defined('US_CONN_TIMES_PORT')) define( 'US_CONN_TIMES_PORT', 1433);
if(!defined('US_CONN_TIMES_CHECK_PORT')) define( 'US_CONN_TIMES_CHECK_PORT', TRUE);
if(!defined('US_CONN_TIMES_CHECK_STATUS_PORT')) define( 'US_CONN_TIMES_CHECK_STATUS_PORT', false);
if(!defined('US_CONN_TIMES_SERVER_NAME')) define( 'US_CONN_TIMES_SERVER_NAME', "servername.database.windows.net");

if(!defined('US_TSQL_EXECUTE_SELECT_1')) define( 'US_TSQL_EXECUTE_SELECT_1', false);
if(!defined('US_TSQL_EXECUTE_SELECT_NVARCHAR')) define( 'US_TSQL_EXECUTE_SELECT_NVARCHAR', FALSE);
if(!defined('US_TSQL_TEXT_TO_SELECT_NVARCHAR_EXECUTE')) define( 'US_TSQL_TEXT_TO_SELECT_NVARCHAR_EXECUTE', "SELECT COUNT(1) as X FROM PerformanceVarcharNVarchar WHERE TextToSearch = CONVERT(NVARCHAR(MAX),?)");


if(!defined('US_CONN_DSN_NAMEx')) define( 'US_CONN_DSN_NAMEx', "odbc:Driver={ODBC Driver 17 for SQL Server};server=".US_CONN_TIMES_PROTOCOL.":".US_CONN_TIMES_SERVER_NAME.",".US_CONN_TIMES_PORT.";Database=DatabaseName;Connection Timeout=30;Timeout=1;QueryTimeout=1");
if(!defined('US_CONN_DSN_NAME')) define( 'US_CONN_DSN_NAME', "sqlsrv:server=".US_CONN_TIMES_PROTOCOL.":".US_CONN_TIMES_SERVER_NAME.",".US_CONN_TIMES_PORT.";Database=DatabaseName");
if(!defined('US_CONN_USER_NAME')) define( 'US_CONN_USER_NAME',"<UserName>");
if(!defined('US_CONN_USER_PWD')) define( 'US_CONN_USER_PWD',"<Password>");
if(!defined('US_TSQL_EXECUTE_TIMEOUT')) define( 'US_TSQL_EXECUTE_TIMEOUT', 3);
if(!defined('US_OUTPUT_FILE')) define( 'US_OUTPUT_FILE', "Output.log");


if (!function_exists('SaveResults'))
{
function SaveResults($text)
{
try
{
    $date   = new DateTime();
    file_put_contents(US_OUTPUT_FILE, date_format($date,"Y/m/d H:i:s")." ".$text."\n", FILE_APPEND);
    echo ($text . PHP_EOL);
  }
   catch(Exception $e)
  {
   echo "Error connecting to .. " . $e->getMessage();
  }
}
}

?>