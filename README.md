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
         
      
Enjoy!
