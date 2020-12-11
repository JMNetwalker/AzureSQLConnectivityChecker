

import java.sql.*;


public class ClsRetryLogic {
    private Connection oConnection;
    private boolean bClose = true;
    public boolean HazUnaConexionConReintentos(String sConnection)
    {
     int retryIntervalSeconds = 10;
     double calculation;
     boolean returnBool=false;
    
     for (int tries = 1; tries <= 5; tries++)
     {
       try
         { 
          if(tries>1) 
          {
            System.out.println("Waiting time: " + retryIntervalSeconds);
            Thread.sleep(1000 * retryIntervalSeconds);
            calculation = retryIntervalSeconds * 1.5;
            retryIntervalSeconds = (int) calculation;            
          }
         System.out.println("Connecting to Database");
         oConnection = DriverManager.getConnection(sConnection);
         System.out.println("Connected to Database");         
         returnBool = true;
         break;
         }
       catch(Exception e)
       {
        System.out.println("Error connecting to .. " + e.getMessage());
       }  
    }  
    return returnBool;
}

  public Connection getConn() {
    return oConnection;
  }

  public void setCloseConnection(boolean bCloseIndicator)
  {
      this.bClose=bCloseIndicator;
  }

  public boolean getCloseConnection()
  {
      return this.bClose;
  }

}
