#!/bin/bash

#
# Tested CentOS 5.5
# Database software installation, run as root user
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

yum_repo CentOS-5

#/etc/hosts configuration
echo "`ip route get 1 | awk '{print $NF;exit}'` `hostname`" >> /etc/hosts


# Kernel parameters tuning
kernel_params $O_VER

iptables_off

# SELinux should be disabled
selinux_disabled

groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper $O_USER

#Specify oracle password
passwd $O_USER <<EOF
$O_PASS
$O_PASS
EOF

echo "export PATH
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$CDB
export ORACLE_TERM=xterm
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

#export LD_LIBRARY_PATH CLASSPATH

if [ $USER = "$O_USER" ]; then
  if [ $SHELL = "/bin/ksh" ];then
    ulimit -p 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi" >> /home/$O_USER/.bash_profile

#Create directories for software and database
cr_directories

echo "$O_USER soft nproc 2047
$O_USER hard nproc 16384
$O_USER soft nofile 1024
$O_USER hard nofile 65536" >> /etc/security/limits.conf

echo "session required pam_limits.so" >> /etc/pam.d/login

# Required packages
yum install binutils -y
yum install compat-db -y
yum install compat-libstdc++-296 -y
yum install compat-libstdc++-33 -y
yum install control-center -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc-common -y
yum install glibc-devel -y
yum install glibc-headers -y
yum install ksh -y
yum install libaio -y
yum install libgcc -y
yum install libgnome -y
yum install libgnomeui -y
yum install libgomp -y
yum install libstdc++ -y
yum install libstdc++-devel -y
yum install libXp -y
yum install libXtst -y
yum install make -y
yum install sysstat -y

chown $O_USER:oinstall $ORACLE_SW1

echo "rm -rf $ORACLE_SW_STG
mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
if [ -f "${ORACLE_SW1%.*}" ]; then 
  cpio -idmv < "${ORACLE_SW1%.*}";
else
  gunzip < $ORACLE_SW1 > "${ORACLE_SW1%.*}"
  cpio -idmv < "${ORACLE_SW1%.*}";
fi
#runInstaller SILENT
$ORACLE_SW_STG/database/runInstaller -waitforcompletion -silent -ignoreSysPrereqs \
FROM_LOCATION=$ORACLE_SW_STG/database/stage/products.xml \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=$ORACLE_BASE/oraInventory \
ORACLE_HOME=${ORACLE_HOME} \
ORACLE_HOME_NAME="OraDb10g_Home1" \
ORACLE_BASE=${ORACLE_BASE} \
INSTALL_TYPE="EE" \
oracle.install.db.isCustomInstall=false \
oracle.install.db.DBA_GROUP=dba \
oracle.install.db.OPER_GROUP=dba \
DECLINE_SECURITY_UPDATES=true" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw

# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# post root tasks
$ORACLE_BASE/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh<<EOF
/usr/local/bin
EOF

# Cleanup
rm -f ${SCRIPT_DIR}/inst_ora_sw
# cpio
rm -f "${ORACLE_SW1%.*}"
rm -rf $ORACLE_SW_STG
