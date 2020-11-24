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
      
Enjoy!
