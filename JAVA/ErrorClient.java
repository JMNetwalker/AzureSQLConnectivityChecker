
import java.sql.*;

public class ErrorClient {
    private boolean bClose = true;
    private boolean bReadingSQLData = true;
    private int iTotalIteractions = 1;
    private int iDelay=0;
    private String sSQLConnection = "";
    private String sSQLToExecuteRead = "";
    private int iTimeSQLCommandTimeout=30;

    public void LoadData() throws SQLException 
    {
    ClsRetryLogic[] oRetryLogic = new ClsRetryLogic[this.getTotalIteractions()];
    for(int i=0;i<this.getTotalIteractions();i++)
    {
      oRetryLogic[i]=new ClsRetryLogic();  
      oRetryLogic[i].setCloseConnection(bClose);
      System.out.println("Interaction # " + i);
      if( oRetryLogic[i].HazUnaConexionConReintentos(this.getSQLConnection() ));
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

    public void setSQLConnection(String sSQL)
    {
        this.sSQLConnection=sSQL;
    }
  
    public String getSQLConnection()
    {
        return this.sSQLConnection;
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
 

}
