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

#Configuring the Kernel Parameter Settings
echo "fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf

#Run the following command to change the current kernel parameters.
/sbin/sysctl -p

#Setting Shell Limits for the Oracle User
echo "$O_USER   soft   nofile    1024
$O_USER   hard   nofile    65536
$O_USER   soft   nproc    16384
$O_USER   hard   nproc    16384
$O_USER   soft   stack    10240
$O_USER   hard   stack    32768
$O_USER   hard   memlock    134217728
$O_USER   soft   memlock    134217728" > /etc/security/limits.conf

# OL6 and OL7 (RHEL6 and RHEL7)
yum install binutils -y
yum install compat-libcap1 -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install glibc -y
yum install glibc.i686 -y
yum install glibc-devel -y
yum install glibc-devel.i686 -y
yum install ksh -y
yum install libaio -y
yum install libaio.i686 -y
yum install libaio-devel -y
yum install libaio-devel.i686 -y
yum install libX11 -y
yum install libX11.i686 -y
yum install libXau -y
yum install libXau.i686 -y
yum install libXi -y
yum install libXi.i686 -y
yum install libXtst -y
yum install libXtst.i686 -y
yum install libgcc -y
yum install libgcc.i686 -y
yum install libstdc++ -y
yum install libstdc++.i686 -y
yum install libstdc++-devel -y
yum install libstdc++-devel.i686 -y
yum install libxcb -y
yum install libxcb.i686 -y
yum install make -y
yum install nfs-utils -y
yum install net-tools -y
yum install smartmontools -y
yum install sysstat -y
yum install unixODBC -y
yum install unixODBC-devel -y

# Required for 12.1, not listed for 12.2
yum install gcc -y
yum install gcc-c++ -y
yum install libXext -y
yum install libXext.i686 -y
yum install zlib-devel -y
yum install zlib-devel.i686 -y

# OL6 only (RHEL6 only)
yum install e2fsprogs -y
yum install e2fsprogs-libs -y
yum install libs -y
yum install libxcb.i686 -y
yum install libxcb -y

#Create the new groups and users
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper

useradd -u 54321 -g oinstall -G dba,oper $O_USER

#Specify oracle password
passwd $O_USER <<EOF
$O_PASS
$O_PASS
EOF

#Set secure Linux to permissive
echo "# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
#SELINUX=enforcing
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted" > /etc/selinux/config

setenforce Permissive

#Stop and disable firewalld
firewall_off

#Create directories for software and database
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_APP_ROOT $ORACLE_DB
chmod -R 775 $ORACLE_APP_ROOT $ORACLE_DB

#.bash_profile
echo "# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP
export ORACLE_HOSTNAME=`hostname`
export ORACLE_UNQNAME=$CDB
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORA_INVENTORY=$ORACLE_APP_ROOT/oraInventory
export ORACLE_SID=$CDB
export PDB_NAME=$PDB
export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=$ORACLE_HOME/bin:\$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib" >> /home/$O_USER/.bash_profile

# Create a shell script to unzip and runInstaller
echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
unzip -oq $ORACLE_SW1
unzip -oq $ORACLE_SW2
#runInstaller SILENT
$ORACLE_SW_STG/database/runInstaller -ignorePrereq -waitforcompletion -silent  \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=\${ORACLE_HOSTNAME}                                        \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=\${ORA_INVENTORY}                                       \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.DBA_GROUP=dba                                          \
    oracle.install.db.OPER_GROUP=dba                                           \
    oracle.install.db.BACKUPDBA_GROUP=dba                                    \
    oracle.install.db.DGDBA_GROUP=dba                                        \
    oracle.install.db.KMDBA_GROUP=dba                                        \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true" > ${SCRIPT_DIR}/inst_oracle_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_oracle_sw
#chown $O_USER:oinstall $ORACLE_SW
chmod a+r $ORACLE_SW1
chmod a+r $ORACLE_SW2

# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_oracle_sw

# execute last 2 scripts as root
$ORACLE_APP_ROOT/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh

rm -f ${SCRIPT_DIR}/inst_oracle_sw
