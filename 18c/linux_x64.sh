#!/bin/bash

#
# Tested CentOS 7
#
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

# Source function.sh
source function.sh
#num_lines=$( lines_in_file $1 )
#echo The file $1 has $num_lines lines in it.

#/etc/hosts configuration
echo "`ip -f inet addr show $NIC | grep -Po 'inet \K[\d.]+'` `hostname`" >> /etc/hosts

# Kernel parameters tuning
kernel_params $O_VER

#Setting Shell Limits for the Oracle User
echo "$O_USER   soft   nofile    1024
$O_USER   hard   nofile    65536
$O_USER   soft   nproc    16384
$O_USER   hard   nproc    16384
$O_USER   soft   stack    10240
$O_USER   hard   stack    32768
$O_USER   hard   memlock    134217728
$O_USER   soft   memlock    134217728" > /etc/security/limits.conf

#The following packages are listed as required, including the 32-bit version of some of the packages. Many of the packages should be installed already.
yum install -y bc    
yum install -y binutils
yum install -y compat-libcap1
yum install -y compat-libstdc++-33
yum install -y compat-libstdc++-33.i686
yum install -y elfutils-libelf.i686
yum install -y elfutils-libelf
yum install -y elfutils-libelf-devel.i686
yum install -y elfutils-libelf-devel
yum install -y fontconfig-devel
yum install -y glibc.i686
yum install -y glibc
yum install -y glibc-devel.i686
yum install -y glibc-devel
yum install -y ksh
yum install -y libaio.i686
yum install -y libaio
yum install -y libaio-devel.i686
yum install -y libaio-devel
yum install -y libX11.i686
yum install -y libX11
yum install -y libXau.i686
yum install -y libXau
yum install -y libXi.i686
yum install -y libXi
yum install -y libXtst.i686
yum install -y libXtst
yum install -y libgcc.i686
yum install -y libgcc
yum install -y librdmacm-devel
yum install -y libstdc++.i686
yum install -y libstdc++
yum install -y libstdc++-devel.i686
yum install -y libstdc++-devel
yum install -y libxcb.i686
yum install -y libxcb
yum install -y make
yum install -y nfs-utils
yum install -y net-tools
yum install -y python
yum install -y python-configshell
yum install -y python-rtslib
yum install -y python-six
yum install -y smartmontools
yum install -y sysstat
yum install -y targetcli
yum install -y unixODBC
yum install -y unzip
yum install -y gcc-c++

#oracle user and groups creation
cr_user_and_groups

#Set secure Linux to permissive
selinux_mode permissive

#Stop and disable firewalld
firewall_off

#Create directories for software and database
cr_directories

#.bash_profile
cr_profile $O_VER

# Create a shell script to unzip and runInstaller
echo "cd $ORACLE_HOME
unzip -oq $ORACLE_SW

#runInstaller SILENT
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=\${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=\${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true" > ${SCRIPT_DIR}/inst_oracle_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_oracle_sw
#chown $O_USER:oinstall $ORACLE_SW
chmod a+r $ORACLE_SW

# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_oracle_sw

# execute last 2 scripts as root
$ORACLE_APP_ROOT/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh

rm -f ${SCRIPT_DIR}/inst_oracle_sw
