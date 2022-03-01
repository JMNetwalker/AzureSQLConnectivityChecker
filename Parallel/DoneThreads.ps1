
#Obtain the status for every BackgroundJob

Function lGiveID([Parameter(Mandatory=$false)] [int] $lMax)
{ 
 $Jobs = Get-Job
 [int]$lPending=0
 [int]$lRunning=0

 Foreach ($di in $Jobs)
 {
   if($di.State -eq "Running")
   {$lPending=$lPending+1}
 } 
 if($lPending -lt $lMax) {return $true}
 return {$false}

}
  
try
{
 $i=0;
 #Execute 2000 operations in groups of 5 at the same time. 
 while ($i -lt 2000)
 {
  if((lGiveid(5)) -eq $true)
  {
   Start-Job -FilePath "C:\Test\DoneThreadIndividual1.ps1" -ArgumentList $i
   Write-output "Starting Up---"
   $i=$i+1;
  }
  else
  {
    Write-output "Limit reached..Waiting to have more resources.."
    Start-sleep -Seconds 20
  }
 }
}
 catch
   {
    logMsg( "You're WRONG") (2)
    logMsg($Error[0].Exception) (2)
   }
