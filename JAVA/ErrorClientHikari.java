package testconnectionms;
import java.sql.*;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;


public class ErrorClientHikari {
    private boolean bClose = true;
    private boolean bReadingSQLData = true;
    private int iTotalIteractions = 1;
    private int iDelay=0;
    private String sSQLToExecuteRead = "";
    private int iTimeSQLCommandTimeout=30;
    private DataSource DS;

    private String sSQLServerName = "";
    private String sSQLDatabaseName = "";
    private String sSQLUserName = "";
    private String sSQLPassword = "";

    private int iMaximumPoolSize=0;
    private int iConnectionTimeout=0;

    public void LoadData() throws SQLException 
    {
    this.DS = getDataSource();
    ClsRetryLogicHikari[] oRetryLogic = new ClsRetryLogicHikari[this.getTotalIteractions()];
    for(int i=0;i<this.getTotalIteractions();i++)
    {
      oRetryLogic[i]=new ClsRetryLogicHikari();  
      oRetryLogic[i].setCloseConnection(bClose);
      oRetryLogic[i].setDS(this.DS);
      System.out.println("Interaction # " + i);
      if( oRetryLogic[i].HazUnaConexionConReintentos());
      {
        if(this.getReadingSQLData())
        {
         readData(oRetryLogic[i].getConn());
        }  
        if(oRetryLogic[i].getCloseConnection())
        {
            oRetryLogic[i].getConn().close();
        }
      }
    }
}
    private void readData(Connection connection) {
    for (int tries = 1; tries <= 5; tries++)
     {        
      try
       {
        System.out.println("Reading Data! " + this.getSQLReadToExecute());
        PreparedStatement readStatement = connection.prepareStatement(this.getSQLReadToExecute());
        readStatement.setQueryTimeout(this.getSQLCommandTimeout());
        ResultSet resultSet = readStatement.executeQuery();
        while(resultSet.next())
        {
          System.out.println(resultSet.getLong("id"));
        }  
        break;
      }   
      catch(Exception e)
      {
       System.out.println("Reading Data " + tries + " - Error  .. " + e.getMessage());
      }  
     }
    }

    public void setCloseConnection(boolean bCloseIndicator)
    {
        this.bClose=bCloseIndicator;
    }
  
    public boolean getCloseConnection()
    {
        return this.bClose;
    }

    public void setReadingSQLData(boolean bReadingSQLData)
    {
        this.bReadingSQLData=bReadingSQLData;
    }
  
    public boolean getReadingSQLData()
    {
        return this.bReadingSQLData;
    }

    public void setTotalIteractions(int iTotalIteractions)
    {
        this.iTotalIteractions=iTotalIteractions;
    }
  
    public int getTotalIteractions()
    {
        return this.iTotalIteractions;
    }

    public void setDelay(int iDelay)
    {
        this.iDelay=iDelay;
    }
  
    public int getDelay()
    {
        return this.iDelay;
    }

    public void setSQLReadToExecute(String sSQL)
    {
        this.sSQLToExecuteRead=sSQL;
    }
  
    public String getSQLReadToExecute()
    {
        return this.sSQLToExecuteRead;
    }
    public void setSQLCommandTimeout(int i)
    {
        this.iTimeSQLCommandTimeout=i;
    }
  
    public int getSQLCommandTimeout()
    {
        return this.iTimeSQLCommandTimeout;
    }
 
      // Get DataSource object from Hikari config
      public DataSource getDataSource() {
   
        HikariConfig config = new HikariConfig();
        // Mimic ADO.NET connection pool default
        config.setMinimumIdle(0);
        config.setMaximumPoolSize(100);
        config.setDataSourceClassName("com.microsoft.sqlserver.jdbc.SQLServerDataSource");
        config.addDataSourceProperty("serverName", this.getServerName());
        config.addDataSourceProperty("databaseName", this.getDatabaseName());
        config.addDataSourceProperty("user", this.getUserName());
        config.addDataSourceProperty("password", this.getPassword());
        // socketTimeout significantly longer than average query response
        config.addDataSourceProperty("socketTimeout", 8000);
        // timeout for getting a connection from the pool
        config.setConnectionTimeout(this.getConnectionTimeout());
        // max lifetime of a connection in the pool
        config.setMaxLifetime(30000);
        // check if a connection is still alive
        config.setValidationTimeout(5000);
        config.setIdleTimeout(this.getConnectionTimeout()*2);
        config.setMaximumPoolSize(this.getMaximumPoolSize());
        config.setPoolName("DotNetExample");

        return new HikariDataSource(config);  
    }

    public void setServerName(String ServerName)
    {
        this.sSQLServerName=ServerName;
    }
  
    public String getServerName()
    {
        return this.sSQLServerName;
    }

    public void setDatabaseName(String DatabaseName)
    {
        this.sSQLDatabaseName=DatabaseName;
    }
  
    public String getDatabaseName()
    {
        return this.sSQLDatabaseName;
    }

    public void setUserName(String UserName)
    {
        this.sSQLUserName=UserName;
    }
  
    public String getUserName()
    {
        return this.sSQLUserName;
    }

    public void setPassword(String Password)
    {
        this.sSQLPassword=Password;
    }
  
    public String getPassword()
    {
        return this.sSQLPassword;
    }

    public void setMaximumPoolSize(int MaximumPoolSize)
    {
        this.iMaximumPoolSize=MaximumPoolSize;
    }
  
    public int getMaximumPoolSize()
    {
        return this.iMaximumPoolSize;
    }

    public void setConnectionTimeout(int Timeout)
    {
        this.iConnectionTimeout=Timeout;
    }
  
    public int getConnectionTimeout()
    {
        return this.iConnectionTimeout;
    }

}
