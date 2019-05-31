
#!/bin/bash

#
# Tested CentOS Linux release 7.6.1810 (Core)
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

echo "inventory_loc=$ORACLE_BASE/oraInventory" > /etc/oraInst.loc
chown $O_USER:oinstall /etc/oraInst.loc
chmod 777 /etc/oraInst.loc


# Kernel parameters tuning
kernel_params $O_VER

#Setting Shell Limits for the Oracle User
echo "oracle              soft    nproc   2047
oracle              hard    nproc   16384
oracle              soft    nofile  4096
oracle              hard    nofile  65536
oracle              soft    stack   10240" > /etc/security/limits.conf

echo "session    required     pam_limits.so" >> /etc/pam.d/login

#The following packages are listed as required, including the 32-bit version of some of the packages. Many of the packages should be installed already.
yum install binutils -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc.i686 -y
yum install glibc-devel -y
yum install glibc-devel.i686 -y
yum install ksh -y
yum install libgcc -y
yum install libgcc.i686 -y
yum install libstdc++ -y
yum install libstdc++.i686 -y
yum install libstdc++-devel -y
yum install libstdc++-devel.i686 -y
yum install libaio -y
yum install libaio.i686 -y
yum install libaio-devel -y
yum install libaio-devel.i686 -y
yum install libXext -y
yum install libXext.i686 -y
yum install libXtst -y
yum install libXtst.i686 -y
yum install libX11 -y
yum install libX11.i686 -y
yum install libXau -y
yum install libXau.i686 -y
yum install libxcb -y
yum install libxcb.i686 -y
yum install libXi -y
yum install libXi.i686 -y
yum install make -y
yum install sysstat -y
yum install unixODBC -y
yum install unixODBC-devel -y
yum install zlib-devel -y
yum install elfutils-libelf-devel -y
yum install -y unzip

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
echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
unzip $ORACLE_SW1
unzip $ORACLE_SW2

#runInstaller SILENT
$ORACLE_SW_STG/database/runInstaller -waitforcompletion -silent -force \
FROM_LOCATION=$ORACLE_SW_STG/database/stage/products.xml \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=$ORACLE_APP_ROOT/oraInventory \
ORACLE_HOME=${ORACLE_HOME} \
ORACLE_HOME_NAME="OraDb11g_Home1" \
ORACLE_BASE=${ORACLE_BASE} \
oracle.install.db.InstallEdition=EE \
oracle.install.db.isCustomInstall=false \
oracle.install.db.DBA_GROUP=dba \
oracle.install.db.OPER_GROUP=dba \
DECLINE_SECURITY_UPDATES=true" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw

# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# execute last 2 scripts as root

##$ORACLE_APP_ROOT/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh

rm -rf $ORACLE_SW_STG
rm -f ${SCRIPT_DIR}/inst_ora_sw
