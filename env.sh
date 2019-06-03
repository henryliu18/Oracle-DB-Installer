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
elif [ "$O_VER" = "12c" ]; then
  echo "Oracle Database zip file [/tmp/p17694377_121020_Linux-x86-64_1of8.zip]: "; read ORACLE_SW1
  ORACLE_SW1=${ORACLE_SW1:-/tmp/p17694377_121020_Linux-x86-64_1of8.zip}
  if [ ! -f $ORACLE_SW1 ]; then
   echo -e "${RED}$ORACLE_SW1 not found, exiting${OFF}"
   exit 1
  fi
  echo "Oracle Database zip file [/tmp/p17694377_121020_Linux-x86-64_2of8.zip]: "; read ORACLE_SW2
  ORACLE_SW2=${ORACLE_SW2:-/tmp/p17694377_121020_Linux-x86-64_2of8.zip}
  if [ ! -f $ORACLE_SW2 ]; then
   echo -e "${RED}$ORACLE_SW2 not found, exiting${OFF}"
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
  ORACLE_SW1=${ORACLE_SW1:-/tmp/linux81701.tar.bz2}
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
elif [ "$O_VER" = "12c" ]; then
  echo "Location of staging directory [/tmp/ora12c]: "; read ORACLE_SW_STG
  ORACLE_SW_STG=${ORACLE_SW_STG:-/tmp/ora12c}
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

if [ "$O_VER" = "8.1.7" ] || [ "$O_VER" = "9.2" ]; then
  echo "XMING IP [192.168.56.1]: "; read XMING_IP
  XMING_IP=${XMING_IP:-192.168.56.1}
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
CDB=${CDB}
XMING_IP=${XMING_IP}" > `dirname $0`/env

if [ $? -eq 0 ]; then
this_id=`id -u`
OHROOT=`dirname ${ORACLE_APP_ROOT}`
diskfree=`df $OHROOT | awk '/[0-9]%/{print $(NF-2)}'`
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [ $this_id -ne 0 ]; then
  echo -e "${RED}you are not root${OFF}"
  exit 1
elif [ ! "command -v unzip" ]; then
  echo -e "${RED}unzip not found${OFF}"
  exit 1
elif [ ! "command -v tar" ]; then
  echo -e "${RED}tar not found${OFF}"
  exit 1
elif [ ! "command -v yum" ]; then
  echo -e "${RED}yum not found${OFF}"
  exit 1
elif [ "$OS" = "CentOS Linux" ] && [ ! $VER -eq 8 ] && [ ! $VER -eq 7 ] && [ ! $VER -eq 6 ]; then
  echo -e "${RED}$OS $VER incompatible${OFF}"
  exit 1
elif [ ! -f ${ORACLE_SW} ]; then
  echo -e "${RED}Oracle DB software not found${OFF}"
  exit 1
elif ! ping -q -c 1 -W 1 www.google.com >/dev/null; then
  echo -e "${RED}IPv4 is down${OFF}"
  exit 1
elif [ $diskfree -lt 20000000 ]; then
  echo -e "${RED}Storage too small${OFF}"
  exit 1
else
  echo Readiness Check
  echo "OS check..........[$OS-$VER]"
  echo "uid check..........[$this_id]"
  echo "unzip check..........[`command -v unzip>/dev/null 2>&1;echo $?`]"
  echo "tar check..........[`command -v tar>/dev/null 2>&1;echo $?`]"
  echo "yum check..........[`command -v yum>/dev/null 2>&1;echo $?`]"
  echo "Oracle DB software check..........[`ls ${ORACLE_SW}>/dev/null 2>&1;echo $?`]"
  echo "APEX software check..........[`ls ${APEX_SW}>/dev/null 2>&1;echo $?`]"
  echo "ORDS software check..........[`ls ${ORDS_SW}>/dev/null 2>&1;echo $?`]"
  echo "Internet check..........[`ping -q -c 1 -W 1 www.google.com>/dev/null 2>&1;echo $?`]"
  echo "Disk check..........["$OHROOT-$diskfree KB free"]"
  echo "**************************************************************"
  echo "*** env saved in `dirname $0`/env *"
  echo "**************************************************************"
  exit 0
fi

else
 echo "`dirname $0`/env saved failed";
fi
