
public class Main {
    public static void mainwithoutHikari(String[] args) throws Exception{
        System.out.println("Testing connection JAVA!");
        ErrorClient oErrorClient = new ErrorClient();
                    oErrorClient.setCloseConnection(false);
                    oErrorClient.setReadingSQLData(true);
                    oErrorClient.setTotalIteractions(30000);
                    oErrorClient.setSQLReadToExecute("SELECT top(20) * FROM PerformanceVarcharNVarchar where TextToSearch =N'Value'");
                    oErrorClient.setSQLCommandTimeout(200);
                    oErrorClient.setSQLConnection("jdbc:sqlserver://servername.database.windows.net:1433;database=DBName;user=username@servername;password=Password;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;");
                    oErrorClient.LoadData();
    }
    
    public static void main(String[] args) throws Exception{
        System.out.println("Testing connection JAVA! (Hikari)");
        ErrorClientHikari oErrorClient = new ErrorClientHikari();
                    oErrorClient.setCloseConnection(false);
                    oErrorClient.setReadingSQLData(false);
                    oErrorClient.setTotalIteractions(30000);
                    oErrorClient.setSQLReadToExecute("SELECT count(*) Id FROM PerformanceVarcharNVarchar where TextToSearch =N'Value'");
                    oErrorClient.setSQLCommandTimeout(30000);
                    oErrorClient.setServerName("servername.database.windows.net");
                    oErrorClient.setDatabaseName("DBNAme");
                    oErrorClient.setUserName("UserName");
                    oErrorClient.setPassword("Password");
                    oErrorClient.setMaximumPoolSize(50);
                    oErrorClient.setConnectionTimeout(5000);
                    oErrorClient.LoadData();
    }

}



