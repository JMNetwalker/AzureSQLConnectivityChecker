#!/bin/bash
#################################################################################################################################
#title           :connectivityDiag.sh
#description     :This script will launch a continuous connectivity test to databases like SQL, PostgreSQL, MySQL and MariaDB
#authors		 :Francisco Javier Pardillo & Jose Manuel Jurado
#date            :20201112
#version         :0.1
#usage		     :./connectivityDiag.sh
#notes           :Install "iproute","hostname" and some of the database clients ["sqlcmd","mysql","psql"] to use this script.
#################################################################################################################################
LY='\033[1;33m' # Light Yellow
LR='\033[1;31m' # Light Red
LG='\033[1;32m' # Light Green
NC='\033[0m' # No Color
i=`tput cols`;FL="";while [ $i -gt 0 ]; do FL=$FL\#;i=`expr $i - 1`; done #FL=FILL LINE
for i in "$@"
do
case $i in
    -h|--help)
	echo -e "\n\nInteractive Deployment Proccess (HELP)"
	echo -e $FL$LG
	echo -e "\n\nUSAGE$NC"
	echo -e "\n./install_db.sh -h"
	echo -e "	This help"
	echo -e "\n./install_db.sh"
	echo -e "	Connectivity Diagnostic Script, will ask for parameters: username, password, database name, host, port, dbtype, logdirectory, notes"
	echo -e $NC
	exit 0
    ;;
    *)
	#Nothing, will go ahead with non-interactive install
    ;;
esac
done

echo -e "\n\nInteractive Connectivity Diagnostic Proccess"
echo -e $FL$LG
echo -e "Please insert USERNAME"
read DB_USER; 
echo "Please insert PASSWORD"
read -s DB_PASS
echo "Please insert DATABASE NAME, EJ.- dbname"
read DB; 
echo "Please insert complete Database ServerName (fqdn), EJ.- server.database.windows.net"
read SERVER
echo "Please insert PORT of the Database Server, EJ.- 1433 (Default: 1433)"
read PORT
echo "Please insert Database Type,allowed values:[sql,postgresql,mysql], EJ.- server.database.windows.net"
read SERVERTYPE
echo "Please insert QUERY to test connectivity, EJ.- SELECT 1 (Default: SELECT 1)"
read TEST_QUERY
echo "Please insert wait time (seconds) between tests, EJ.- 1 (Default: 1)"
read TEST_WAIT
echo "Please insert number of tests to perform, EJ.- 86400 (Default: 86400)"
read TEST_LOOPS
echo "Please insert NOTES of this connectivityDiag session, EJ.- TEST1 (Default: test)"
read NOTES
echo "Would you like to DEBUG all commands? (Y/N) (Default=N)"
read DEBUG
	
DIR=`pwd`;
DIR_LOGS="connectivityDiag_logs";

echo -e $NC

exit_condition="N"
date_time=`date "+%Y%m%d%H%M%S"`
current_dir=`pwd`

if [ "$SERVER""a" = "a" ]; then SERVER="server.database.windows.net"; fi
if [ "$DB""a" = "a" ]; then DB="DotNetExample"; fi
if [ "$USERNAME""a" = "a" ]; then USERNAME="user"; fi
if [ "$PASSWORD""a" = "a" ]; then PASSWORD="password"; fi
if [ "$SERVERTYPE""a" = "a" ]; then SERVERTYPE="sql"; fi
if [ "$PORT""a" = "a" ]; then PORT="1433"; fi
if [ "$NOTES""a" = "a" ]; then NOTES="test"; fi
if [ "$TEST_QUERY""a" = "a" ]; then TEST_QUERY="SELECT 1"; fi
if [ "$TEST_WAIT""a" = "a" ]; then TEST_WAIT=1; fi
if [ "$TEST_LOOPS""a" = "a" ]; then TEST_LOOPS=86400; fi
if [ "$DEBUG""a" = "a" ]; then DEBUG="N"; fi

# We need an output file per test
logConnectivity=$DIR_LOGS/connectivity.$NOTES.$date_time.csv
logDns=$DIR_LOGS/dns.$NOTES.$date_time.csv
logNetstat=$DIR_LOGS/dns.$NOTES.$date_time.csv
logDebug=$DIR_LOGS/debug.$NOTES.$date_time.log

# DB connections
db_postgresql="psql -h $SERVER -U $USERNAME -w$PASSWORD -d $DB -t";
db_mysql="mysql -N -u $USERNAME -h $SERVER -p$PASSWORD -D $DB";
db_sql="/opt/mssql-tools/bin/sqlcmd -S $SERVER -d $DB -U $USERNAME -P$PASSWORD -h-1";

CHK17="$LG""CHECK.017:Existence of directory $DIR$NC";
CHK18="$LG""CHECK.018:Existence of directory $DIR_LOGS$NC";

CHK19="$LG""CHECK.019:Write permissions on log file $logConnectivity$NC";
CHK20="$LG""CHECK.020:Write permissions on log file $logDns$NC";
CHK21="$LG""CHECK.021:Write permissions on log file $logNetstat$NC";
CHK22="$LG""CHECK.022:Write permissions on log file $logDebug$NC";

CHK100="$LR""CHECK.100.Script execution error:$NC";

#ASUME TO BE IN CURRENT DIRECTORY OF SCRIPT EXECUTION
if [ ! -d $DIR_LOGS ];then echo "Creating $DIR_LOGS directory"; mkdir -p $DIR_LOGS;fi
if [ ! -d $DIR_LOGS ];then exit_message=$exit_message"\nERROR:"$CHK18; exit_condition="Y";echo -e $CHK18"...Error";else echo -e $CHK18"...Ok";fi

touch $logConnectivity
if [ $? -ne 0 ]; then exit_message=$exit_message"\nERROR:"$CHK19; exit_condition="Y";echo -e $CHK19"...Error";else echo -e $CHK19"...Ok";fi
if [ $exit_condition = "Y" ]; then echo -e "\n################################\nCanceling Connectivity Diagnostic test because of:\n"$exit_message; exit 0; fi

touch $logDns
if [ $? -ne 0 ]; then exit_message=$exit_message"\nERROR:"$CHK20; exit_condition="Y";echo -e $CHK20"...Error";else echo -e $CHK20"...Ok";fi
if [ $exit_condition = "Y" ]; then echo -e "\n################################\nCanceling Connectivity Diagnostic test because of:\n"$exit_message; exit 0; fi

touch $logNetstat
if [ $? -ne 0 ]; then exit_message=$exit_message"\nERROR:"$CHK21; exit_condition="Y";echo -e $CHK21"...Error";else echo -e $CHK21"...Ok";fi
if [ $exit_condition = "Y" ]; then echo -e "\n################################\nCanceling Connectivity Diagnostic test because of:\n"$exit_message; exit 0; fi

touch $logDebug
if [ $? -ne 0 ]; then exit_message=$exit_message"\nERROR:"$CHK22; exit_condition="Y";echo -e $CHK22"...Error";else echo -e $CHK22"...Ok";fi
if [ $exit_condition = "Y" ]; then echo -e "\n################################\nCanceling Connectivity Diagnostic test because of:\n"$exit_message; exit 0; fi

# DEFINE AUXILIARY FUNCTIONS 

function logDebug(){
	# $1 should be the starttime, $2 should be the output to be saved, $3 should be the endtime, $4 type of test performed
	duration=$(($3-$1))
	if [ $DEBUG == "Y" ];
	then
		echo "==============================" >> $logDebug
		echo "HOSTNAME:"$HOSTNAME", HOSTIPS:"$HOSTIPS", NOTES:"$NOTES", TEST:"$4", DURATION:"$duration >> $logDebug
		echo "STARTTIME:"$1 >> $logDebug
		echo "OUTPUT:"$2 >> $logDebug
		echo "ENDTIME:"$3 >> $logDebug
	else
		echo "==============================" >> $logDebug
		echo "HOSTNAME:"$HOSTNAME", HOST IPS:"$HOSTIPS", NOTES:"$NOTES", TEST:"$4", DURATION:"$duration >> $logDebug
		echo "TEST:"$4 >> $logDebug
		echo "STARTTIME:"$1 >> $logDebug
		echo "ENDTIME:"$3 >> $logDebug
	fi
}

function chkConnMySQL(){
	start=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	out=$($db_mysql -e "$TEST_QUERY" 2>&1)
	res=$?
	# We need to take output in res and parse with outfin 
	outfin=`echo $out|sed s/,/#/g|sed s/'mysql: \[Warning\] Using a password on the command line interface can be insecure\. '//g`
	end=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	duration=$((end-start))
	if [ $res == 0 ];
	then
		result='OK';
	else
		result='ERR';
	fi
	logDebug $start "$out" $end "MYSQL CONNECTIVITY"
	echo $NOTES,$HOSTIPS,sqlcmd,$HOSTNAME,$start,$duration,$result,$outfin
}
function chkConnPostgreSQL(){
	start=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	out=$($db_postgresql -c "$TEST_QUERY" 2>&1)
	res=$?
	# We need to take output in res and parse with outfin 
	outfin=`echo $out|sed s/,/#/g|sed s/'REMOVABLESTRING'//g`
	end=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	duration=$((end-start))
	if [ $res == 0 ];
	then
		result='OK';
	else
		result='ERR';
	fi
	logDebug $start "$out" $end "POSTGRESQL CONNECTIVITY"
	echo $NOTES,$HOSTIPS,sqlcmd,$HOSTNAME,$start,$duration,$result,$outfin
}
function chkConnSQL(){
	start=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	echo "SET NOCOUNT ON;SELECT $start;$TEST_QUERY"
	out=$($db_sql -Q "SET NOCOUNT ON;SELECT $start;$TEST_QUERY" 2>&1)
	res=$?
	# We need to take output in res and parse with outfin 
	outfin=`echo $out|sed s/,/\#/g|sed s/'(.*rows affected)'//g`
	end=`date +%Y%m%d%H%M%S%N|cut -b1-17`
	duration=$((end-start))
	if [ $res == 0 ];
	then
		result='OK';
	else
		result='ERR';
	fi
	logDebug $start "$out" $end "SQL CONNECTIVITY"
	echo $NOTES,$HOSTIPS,sqlcmd,$HOSTNAME,$start,$duration,$result,$outfin
}

for (( l=1; l<=$TEST_LOOPS; l++ ))
do
	# Execute every loop because ips can change
	HOSTIPS=$(hostname --all-ip-addresses)
	case "$SERVERTYPE" in
	"sql")  
		echo `chkConnSQL` >> $logConnectivity
		;;
	"mysql")  
		echo `chkConnMySQL` >> $logConnectivity
		;;
	"postgresql")  
		echo `chkConnPostgreSQL` >> $logConnectivity
		;;
	*) echo `chkConnSQL` >> $logConnectivity
		;;
	esac
	sleep $TEST_WAIT
done
