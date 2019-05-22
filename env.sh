#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
OFF='\033[0m'

clear
echo "Networking"
ifconfig -a|grep 'inet\|flags\|Link'
echo "Servicable network interface [enp0s8]: "; read NIC
NIC=${NIC:-enp0s8}
ifconfig $NIC
if [ $? -ne 0 ]; then
 echo -e "${RED}$NIC not found, exiting${OFF}"
 exit 1
fi

echo "Oracle version [8.1.7/9.2/10.2/11.2/12c/*18c]: "; read O_VER
O_VER=${O_VER:-18c}

clear
echo "Software (zip file) location"

if [ "$O_VER" = "18c" ]; then
  echo "Oracle Database zip file [/tmp/LINUX.X64_180000_db_home.zip]: "; read ORACLE_SW
  ORACLE_SW=${ORACLE_SW:-/tmp/LINUX.X64_180000_db_home.zip}
  if [ ! -f $ORACLE_SW ]; then
   echo -e "${RED}$ORACLE_SW not found, exiting${OFF}"
   exit 1
  fi
elif [ "$O_VER" = "11.2" ]; then
  echo "Oracle Database zip file [/tmp/linux.x64_11gR2_database_1of2.zip]: "; read ORACLE_SW1
  ORACLE_SW1=${ORACLE_SW1:-/tmp/linux.x64_11gR2_database_1of2.zip}
  if [ ! -f $ORACLE_SW1 ]; then
   echo -e "${RED}$ORACLE_SW1 not found, exiting${OFF}"
   exit 1
  fi
  echo "Oracle Database zip file [/tmp/linux.x64_11gR2_database_2of2.zip]: "; read ORACLE_SW2
  ORACLE_SW2=${ORACLE_SW2:-/tmp/linux.x64_11gR2_database_2of2.zip}
  if [ ! -f $ORACLE_SW2 ]; then
   echo -e "${RED}$ORACLE_SW2 not found, exiting${OFF}"
   exit 1
  fi
elif [ "$O_VER" = "10.2" ]; then
  echo "Oracle Database zip file [/tmp/10201_database_linux_x86_64.cpio.gz]: "; read ORACLE_SW1
  ORACLE_SW1=${ORACLE_SW1:-/tmp/10201_database_linux_x86_64.cpio.gz}
  if [ ! -f $ORACLE_SW1 ]; then
   echo -e "${RED}$ORACLE_SW1 not found, exiting${OFF}"
   exit 1
  fi
elif [ "$O_VER" = "9.2" ]; then
  echo "Oracle Database gz file [/tmp/amd64_db_9204_Disk1.cpio.gz]: "; read ORACLE_SW1
  ORACLE_SW1=${ORACLE_SW1:-/tmp/amd64_db_9204_Disk1.cpio.gz}
  if [ ! -f $ORACLE_SW1 ]; then
   echo -e "${RED}$ORACLE_SW1 not found, exiting${OFF}"
   exit 1
  fi
  echo "Oracle Database gz file [/tmp/amd64_db_9204_Disk2.cpio.gz]: "; read ORACLE_SW2
  ORACLE_SW2=${ORACLE_SW2:-/tmp/amd64_db_9204_Disk2.cpio.gz}
  if [ ! -f $ORACLE_SW2 ]; then
   echo -e "${RED}$ORACLE_SW2 not found, exiting${OFF}"
   exit 1
  fi
  echo "Oracle Database gz file [/tmp/amd64_db_9204_Disk3.cpio.gz]: "; read ORACLE_SW3
  ORACLE_SW3=${ORACLE_SW3:-/tmp/amd64_db_9204_Disk3.cpio.gz}
  if [ ! -f $ORACLE_SW3 ]; then
   echo -e "${RED}$ORACLE_SW3 not found, exiting${OFF}"
   exit 1
  fi
elif [ "$O_VER" = "8.1.7" ]; then
  echo "Oracle Database bz2 file [/tmp/linux81701.tar.bz2]: "; read ORACLE_SW1
  ORACLE_SW1=${ORACLE_SW1:-/tmp/10201_database_linux_x86_64.cpio}
  if [ ! -f $ORACLE_SW1 ]; then
   echo -e "${RED}$ORACLE_SW1 not found, exiting${OFF}"
   exit 1
  fi
  echo "Java software [/tmp/jdk-1_2_2_017-linux-i586.tar.gz]: "; read JAVA_SW
  JAVA_SW=${JAVA_SW:-/tmp/jdk-1_2_2_017-linux-i586.tar.gz}
  if [ ! -f $JAVA_SW ]; then
   echo -e "${RED}$JAVA_SW not found, exiting${OFF}"
   exit 1
  fi
fi

clear
echo "Security"
echo "Oracle account [oracle]: "; read O_USER
O_USER=${O_USER:-oracle}

echo "Oracle account's password [oracle123]: "; read O_PASS
O_PASS=${O_PASS:-oracle123}

echo "(DB) SYS password [SysPassword1]: "; read SYS_PASS
SYS_PASS=${SYS_PASS:-SysPassword1}

echo "(DB) SYSTEM password [SysPassword1]: "; read SYSTEM_PASS
SYSTEM_PASS=${SYSTEM_PASS:-SysPassword1}

if [ "$O_VER" = "18c" ] || [ "$O_VER" = "12c" ]; then
  echo "(DB) PDBADMIN password [PdbPassword1]: "; read PDBADMIN_PASS
  PDBADMIN_PASS=${PDBADMIN_PASS:-PdbPassword1}
fi

clear
echo "Installation location"
echo "\$ORACLE_APP_ROOT (The root directory that will hold oracle database and oraInventory binaries) [/opt/app]: "; read ORACLE_APP_ROOT
ORACLE_APP_ROOT=${ORACLE_APP_ROOT:-/opt/app}

echo "\$ORACLE_BASE (oracle database root directory) [\$ORACLE_APP_ROOT/oracle]: "; read ORACLE_BASE
ORACLE_BASE=${ORACLE_BASE:-\$ORACLE_APP_ROOT/oracle}

echo "\$ORACLE_HOME (oracle database home directory) [\$ORACLE_BASE/product/$O_VER/dbhome_1]: "; read ORACLE_HOME
ORACLE_HOME=${ORACLE_HOME:-\$ORACLE_BASE/product/$O_VER/dbhome_1}

echo "Oracle database files directory [/ora/db001]: "; read ORACLE_DB
ORACLE_DB=${ORACLE_DB:-/ora/db001}

echo "Location of auto generated scripts during installation [/tmp]: "; read SCRIPT_DIR
SCRIPT_DIR=${SCRIPT_DIR:-/tmp}

if [ "$O_VER" = "11.2" ]; then
  echo "Location of staging directory [/tmp/ora11g]: "; read ORACLE_SW_STG
  ORACLE_SW_STG=${ORACLE_SW_STG:-/tmp/ora11g}
elif [ "$O_VER" = "10.2" ]; then
  echo "Location of staging directory [/tmp/ora10g]: "; read ORACLE_SW_STG
  ORACLE_SW_STG=${ORACLE_SW_STG:-/tmp/ora10g}
elif [ "$O_VER" = "9.2" ]; then
  echo "Location of staging directory [/tmp/ora9i]: "; read ORACLE_SW_STG
  ORACLE_SW_STG=${ORACLE_SW_STG:-/tmp/ora9i}
elif [ "$O_VER" = "8.1.7" ]; then
  echo "Location of staging directory [/tmp/ora8i]: "; read ORACLE_SW_STG
  ORACLE_SW_STG=${ORACLE_SW_STG:-/tmp/ora8i}
  echo "JAVA_HOME [/usr/local/java]: "; read JAVA_HOME
  JAVA_HOME=${JAVA_HOME:-/usr/local/java}
fi

echo "Location of oratab [/etc/oratab]: "; read ORATAB
ORATAB=${ORATAB:-/etc/oratab}

clear
echo "Oracle Database"
echo "\$ORACLE_SID - Database database name or container instance name for apex [cdb1]: "; read CDB
CDB=${CDB:-cdb1}

if [ "$O_VER" = "18c" ] || [ "$O_VER" = "12c" ]; then
  echo "Database container name for apex [pdb1]: "; read PDB
  PDB=${PDB:-pdb1}
fi

echo "NIC=${NIC}
O_USER=${O_USER}
O_PASS=${O_PASS}
O_VER=${O_VER}
SYS_PASS=${SYS_PASS}
SYSTEM_PASS=${SYSTEM_PASS}
PDBADMIN_PASS=${PDBADMIN_PASS}
ORACLE_APP_ROOT=${ORACLE_APP_ROOT}
ORACLE_BASE=${ORACLE_BASE}
ORACLE_HOME=${ORACLE_HOME}
ORACLE_DB=${ORACLE_DB}
ORACLE_SW=${ORACLE_SW}
ORACLE_SW1=${ORACLE_SW1}
ORACLE_SW2=${ORACLE_SW2}
ORACLE_SW3=${ORACLE_SW3}
ORACLE_SW_STG=${ORACLE_SW_STG}
JAVA_HOME=${JAVA_HOME}
JAVA_SW=${JAVA_SW}
SCRIPT_DIR=${SCRIPT_DIR}
ORATAB=${ORATAB}
PDB=${PDB}
CDB=${CDB}" > `dirname $0`/env

if [ $? -eq 0 ]; then
 echo "**************************************************************"
 echo "*** env saved in `dirname $0`/env *"
 echo "**************************************************************"
else
 echo "`dirname $0`/env saved failed";
fi
