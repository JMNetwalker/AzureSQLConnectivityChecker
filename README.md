# AzureSQLConnectivityChecker
This application has been designed with a main idea: how to obtain information about the elapsed time in the connectivity process and the query execution to a database of Azure SQL Database.

Basically we need to configure the parameters:

## Connectivity

- **$DatabaseServer** = "xxxxx.database.windows.net" // Azure SQL Server name
- **$Database** = "xxxxxx" // Database Name
- **$Username** = "xxxxxx" // User Name
- **$Password** = "xxxxxx" // Password
- **$Pooling** = $true     // Use connection pooling? --> $true/$false

## Number of interations/executions

  - **$NumberExecutions** =10
  
## Executing this Powershell script, it will be done:
- A number of interactions specified in **$NumberExecutions**
  + For each interaction: 
    + if the file specified **$File** variable exists: All TSQL contains in this file.
    + if the file specified **$File** variable doesn't exist: Will be execute the SELECT 1 statement.
    + It is important to remark that each connection can be used connection pooling depending on value - **$Pooling**.
    + The details of connection time, execution, round trips,etc. obtained directly from the statistics located in the SQLConnection
      object will be save into e:\my.log file.
         
      
# SQLConnectivityOleDBTest.ps1
This application has been designed with a main idea: how to obtain information about the elapsed time in the connectivity process and the query execution to a database of Azure SQL Database using OLEDB Driver.

This PowerShell script you are going to connect and run a SELECT 1 $NumberExecutions in order to review if there is a connectivity issue. Also, Powershell script will check if the port is port and obtain the different states of the ports. 

Basically we need to configure the parameters.

## Connectivity

- **$server**, #ServerName parameter to connect 
- **$user**, #UserName parameter  to connect
- **$password**, #Password Parameter  to connect
- **$Db**, #DBName Parameter  to connect
- **$LogFile** = "C:\ConnReport\Connectivity.Log", #Folder Parameter to save the log file
- **$Pooling** =1, #Use pooling
- **$NumberExecutions** = 100, #Number of operations to perform, (Remember that 100 operations * delay per execution)
- **$Provider** = "MSOLEDBSQL", #Provider
- **$DelayBetweenExecution**=1, #Delay between executions 
- **$PortCX** = "1433", #Port to check
- **$DetailPort**="0" , #Detailed or not the port list
- **$ScanPort** ="1" #Scan de port

# PHPTestConnectivity.php
This application has been designed with a main idea: how to obtain information about the elapsed time in the connectivity process and the query execution to a database of Azure SQL Database using PHP ( ODBC or Microsoft Drivers for PHP for SQL Server). This PHP console script runs in Windows and Linux.

This PHP console script has the main features: 

- **Connect using different driver measuring the time spent**
- **Once you have established the connection runs multiple times the query SELECT 1 measuring the time spent**
- **Once you have established the connection runs multiple times any query that you need with a random parameter measuring the time spent**
- **Check if the port is open**
- **Report all the ports that the client has opened**
- **All the operations will be saved on a file called Output.log**

You need to download the file const.php (for parameter values) and ConnectionDB.php that contains the RetryLogic mecanishm.
Basically we need to configure the parameters.

## Connectivity

- **US_TSQL_TEXT_TO_EXECUTE**, SELECT 1 as X to check a simple query, it is needed to name the column with X.
- **US_TSQL_TIMES_TO_EXECUTE**, How many times the SELECT 1 query will be executed in every connection made.
- **US_CONN_TIMES_TO_EXECUTE**, How many connections will be performed per every test.
- **US_CONN_TIMES_TO_RETRY**, How many connection retries in case of any connection failure
- **US_CONN_TIMES_TO_CLOSE**, Close or not the connection, very useful to reproduce the issue with ephemeral ports exhaustion.
- **US_CONN_TIMES_PROTOCOL**, TCP protocol
- **US_CONN_TIMES_PORT** , Port to use
- **US_CONN_TIMES_CHECK_PORT**, Flag to verify if the port is listening or not.
- **US_CONN_TIMES_CHECK_STATUS_PORT**, Flag to have a complete list of all ports opened in the client machine.
- **US_CONN_TIMES_SERVER_NAME**, Servername to connect
- **US_TSQL_EXECUTE_SELECT_1**, Flag to run or not the SELECT 1 query.
- **US_TSQL_EXECUTE_SELECT_NVARCHAR**, Flag to run a heavy query, for example, conversion implicit.
- **US_TSQL_TEXT_TO_SELECT_NVARCHAR_EXECUTE**, Query text to execute, for example, conversion implicit.
- **US_CONN_DSN_NAME**, ConnectionString
- **US_CONN_USER_NAME**, UserName (default value) to connect to the database, if you run the php using --username="username" this last value will be replaced.
- **US_CONN_USER_PWD**, Password (default value) to connect to the database, if you run the php using --password="password" this last value will be replaced.
- **US_TSQL_EXECUTE_TIMEOUT**, TimeOut for query execution
- **US_OUTPUT_FILE**, Name of the output generated by whole process.

## Simulation cases

- **Ephemeral ports exhaustion**
    If you change the parameter of **US_CONN_TIMES_TO_CLOSE** with value false and you define **US_CONN_TIMES_TO_EXECUTE** around 5000 ports. You are going to have error messages that there is not possible to open more ports. Normally, you are going to see Login Timeout Expired.

- **Change the name or the port**
    If you change the parameter of **US_CONN_TIMES_CHECK_PORT** to un-existing port you are going to have error messages that there is not possible to open this port and it is not listening. Normally, you are going to see Login Timeout Expired.
    
# Main.java
This application has been designed with a main idea: how to obtain information about the elapsed time in the connectivity process and the query execution to a database of Azure SQL Database using JAVA (Microsoft JDBC Driver for SQL Server). This JAVA console script runs in Windows and Linux.

This JAVA console script has the main features: 

- **Connect using Microsoft JDBC Driver for SQL Server driver measuring the time spent**
- **Once you have established the connection runs multiple times the query SELECT 1 measuring the time spent**

In the Main.Java file you will have the options to run your test, ErrorClient.Java contains all test and ClsRetryLogic contains retry-logic mecanishm.
Basically we need to configure the parameters.

## Connectivity - Methods

- **setCloseConnection**, instructs to close explicit the connection (true) or not (false)
- **setReadingSQLData**, instructs to run or not the T-SQL specified in **setSQLReadToExecute** parameter.
- **setTotalIteractions**, instructs how many connections to make.
- **setSQLCommandTimeout**, instructs how much time for command timeout
- **setSQLReadToExecute**, Close or not the connection, very useful to reproduce the issue with ephemeral ports exhaustion.

## Simulation cases

- **Ephemeral ports exhaustion**
    If you change the parameter of **setCloseConnection** with value false and you define **setTotalIteractions** around 30000 ports. You are going to have error messages that there is not possible to open more ports. Normally, you are going to see Login Timeout Expired.

# Parallel 
This application has been designed with a main idea: how to obtain information about the elapsed time in the connectivity process and the query execution to a database of Azure SQL Database.
It is a new version to run multiple times in parallel the connectivity checker (**DoneThreadIndividual1.ps1**). 

Basically you need to open the file **DoneThreads.ps1** that contains two main things:

- **while ($i -lt 2000)** Number of operations to run
- **if((lGiveid(5)) -eq $true)** how many background jobs in powershell to execute in parallel.

This PowerShell will run as a background job the powershell script **C:\Test\DoneThreadIndividual1.ps1**

## DoneThreadIndividual1.ps1
This powershell script will connect to the database and execute SELECT 1 based the value of the parameter **$NumberExecutions**

You need to configure the parameters:

### Connectivity

- **$DatabaseServer** = "xxxxx.database.windows.net" // Azure SQL Server name
- **$Database** = "xxxxxx" // Database Name
- **$Username** = "xxxxxx" // User Name
- **$Password** = "xxxxxx" // Password
- **$Pooling** = $true     // Use connection pooling? --> $true/$false

### Number of interations/executions

  - **$NumberExecutions** =10
  
### The results
- For every interaction the results will be save on **c:\test\ResultsN.Log**, where **N** is the number of job execute.

# SQLConnectivityTestMultiDriver.ps1
This application has been designed with a main idea: We usually have service requests when our customers, using different drivers, need to know the connection latency, execution time spent or validate the connection.
For this reason, I developed this small PowerShell script  (based on initiative of AzureSQLConnectivityChecker in multiple languages) which will basically connect to the database using 4 drivers/providers and test this.

## Today, we started with SQLConnectivityTestMultiDriver.ps1 PowerShell Script and you are going to be able to:

- **Connect using the drivers**: Net SqlClient, ODBC 17, OLEDB and MSOLEDBSQL.
- **In every interaction**, you could obtain:
  ++ Connectivity latency.
  ++ Time invested in the execution of each query.
  ++ Average time spent on connectivity and per query.
  ++ How many ports the customer application has (1433,11000-12000 and others).
  ++ Check if the DNS is resolving correct IP. 

## Here are the main details:

- **Parameters**, if you don't specify any of them, PowerShell Script will ask the value and check it.

  + **$DatabaseServer**, will be the server name to connect. 
  + **$Database**, will be the database name to connect.
  + **$Username**, user name to connect
  + **$passwordSecure**, password. 
  + **$NumberExecutions**, how many executions that you want to run. 
  + **$LogFile**, will be the log file that all operations will be saved. If this file is not specify, the application will ask the location. 
  + **$Driver** to use, the values are: 
    ++ SQLCLIENT for .NET SQL Client.
    ++ ODBC
    ++ MSOLEDBSQL
    ++ SQLOLEDB
   + $InputFile**, will be the different TSQL that you want to use. This file needs to contain per line the TSQL to execute. If you don't specify it, we are going to use SELECT 1. For example,:
  SELECT 1
  SELECT count(Id) FROM PerformanceVarcharnVarchar Where TextToSearch = N'Test Search ' + CONVERT(nvarchar(200),RAND()*(2000000-10000)+10000) OPTION (MAXDOP 1)

## Outcome:
In the $LogFile you are going to have all the results and summary about connection and execution spent, for example, 

    2022-08-11 03:33:15 Driver: SQLOLEDB
    2022-08-11 03:33:15 Connecting to the database: servername.database.windows.net - DB: dbname...Attempt #1 of 5 - IP:52.138.224.1
    2022-08-11 03:33:16 Connected to the database in (ms):324.1887 - Provider:SQLOLEDB -- HostName: Server Version:12.00.0312
    2022-08-11 03:33:16 Total Connections Failed : 0
    2022-08-11 03:33:16 Total Connections Success: 1
    2022-08-11 03:33:16 Total Connections ms : 324
    2022-08-11 03:33:16 Ports Count : 1433 0 (0) 11xx: (0) Others:(215)
    2022-08-11 03:33:16 Ports Status:
    2022-08-11 03:33:16 ---->Established (207)
    2022-08-11 03:33:16 ---->TimeWait (5)
    2022-08-11 03:33:16 ---->SynSent (2)
    2022-08-11 03:33:16 -------------------------------------------------------------------------------------
    2022-08-11 03:33:16 Query : SELECT 1
    2022-08-11 03:33:16 Iteration : 1 Query 1 / 2
    2022-08-11 03:33:16 Time required (ms) : 41,416
    2022-08-11 03:33:16 Query Commands Failed : 0
    2022-08-11 03:33:16 Query Commands Success: 1
    2022-08-11 03:33:16 Query Commands ms : 41
    2022-08-11 03:33:16 Total Commands Failed : 0
    2022-08-11 03:33:16 Total Commands Success: 1
    2022-08-11 03:33:16 TotalCommands ms : 41
    2022-08-11 03:33:16 -------------------------------------------------------------------------------------
    2022-08-11 03:33:16 Query : SELECT count(Id) FROM PerformanceVarcharnVarchar Where TextToSearch = N'Test Search ' + CONVERT(nvarchar(200),RAND()*(2000000-10000)+10000) OPTION (MAXDOP 1)
    2022-08-11 03:33:16 Iteration : 1 Query 2 / 2
    2022-08-11 03:33:17 Time required (ms) : 473,7891
    2022-08-11 03:33:17 Query Commands Failed : 0
    2022-08-11 03:33:17 Query Commands Success: 1
    2022-08-11 03:33:17 Query Commands ms : 474
    2022-08-11 03:33:17 Total Commands Failed : 0
    2022-08-11 03:33:17 Total Commands Success: 2
    2022-08-11 03:33:17 TotalCommands ms : 257,5
    2022-08-11 03:33:17 ---------------------------------------------------------------------------------------------------------------
    2022-08-11 03:33:17 Connecting to the database: servername.database.windows.net - DB: databasena...Attempt #1 of 5 - IP:52.138.224.1
    2022-08-11 03:33:17 Connected to the database in (ms):0 - Provider:SQLOLEDB -- HostName: Server Version:12.00.0312
    2022-08-11 03:33:17 Total Connections Failed : 0
    2022-08-11 03:33:17 Total Connections Success: 2
    2022-08-11 03:33:17 Total Connections ms : 162
    2022-08-11 03:33:17 Ports Count : 1433 0 (0) 11xx: (0) Others:(215)
    2022-08-11 03:33:17 Ports Status:
    2022-08-11 03:33:17 ---->Established (207)
    2022-08-11 03:33:17 ---->TimeWait (5)
    2022-08-11 03:33:17 ---->SynSent (2)

    2022-08-11 03:38:01 -------------------------------------- SUMMARY -----------------------------------------------------------------
    2022-08-11 03:38:01 Total Connections Failed :0
    2022-08-11 03:38:01 Total Connections Success:200
    2022-08-11 03:38:01 Total Connections Avg ms :2,515
    2022-08-11 03:38:01 Total Number Executions :200
    2022-08-11 03:38:01 Total Number Queries :2
    2022-08-11 03:38:01 Total Number Process :400
    2022-08-11 03:38:01 Total Commands Failed :0
    2022-08-11 03:38:01 Total Commands Success :400
    2022-08-11 03:38:01 Total Commands ms :120,0725
    2022-08-11 03:38:01 ------------------- Queries SummarySELECT count(Id) FROM PerformanceVarcharnVarchar Where TextToSearch = N'Test Search ' + CONVERT(nvarchar(200),RAND()*(2000000-10000)+10000) OPTION (MAXDOP 1)
    2022-08-11 03:38:01 Query # :SELECT 1
    2022-08-11 03:38:01 Total Commands Failed :0
    2022-08-11 03:38:01 Total Commands Success:200
    2022-08-11 03:38:01 Total Commands ms :35,57
    2022-08-11 03:38:01 Query # :SELECT count(Id) FROM PerformanceVarcharnVarchar Where TextToSearch = N'Test Search ' + CONVERT(nvarchar(200),RAND()*(2000000-10000)+10000) OPTION (MAXDOP 1)
    2022-08-11 03:38:01 Total Commands Failed :0
    2022-08-11 03:38:01 Total Commands Success:200
    2022-08-11 03:38:01 Total Commands ms :204,575
    2022-08-11 03:38:01 Review: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/provider-statistics-for-sql-server
    2022-08-11 03:38:01 -------------------------------------- SUMMARY -----------------------------------------------------------------

Enjoy!
