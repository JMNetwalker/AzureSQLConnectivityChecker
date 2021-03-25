package testconnectionms;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.*;

import javax.sql.DataSource;

public class ClsRetryLogicHikari {
    private Connection oConnection;
    private DataSource Ds;
    private boolean bClose = true;
    public boolean HazUnaConexionConReintentos()
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
         oConnection =  this.Ds.getConnection();
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

  public void setDS(DataSource DSTmp)
  {
    this.Ds = DSTmp;
  }

  public boolean getDS()
  {
      return this.Ds;
  }


  public boolean getCloseConnection()
  {
      return this.bClose;
  }


}