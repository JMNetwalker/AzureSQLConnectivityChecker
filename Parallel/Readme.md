**See Readme of the Root folder for more details**

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
