#!/bin/bash

#
# Tested CentOS 5.5
# Database software installation, run as root user
#

NIC=eth0
O_USER=oracle
O_PASS=oracle123
ORACLE_BASE=/opt/app/oracle
ORACLE_HOME=/opt/app/oracle/product/10.2.0/db_1
ORACLE_DB=/ora/db001
ORACLE_SW1=/tmp/10201_database_linux_x86_64.cpio.gz
ORACLE_SW2=/tmp/10201_database_linux_x86_64.cpio
ORACLE_SW_STG=/tmp/ora10g
INST_ORACLE_SW_SHELL=/tmp/inst_ora_sw.sh

echo "# CentOS-Base.repo
#
# This file uses a new mirrorlist system developed by Lance Davis for CentOS.
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
#baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
baseurl=http://vault.centos.org/5.5/os/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5

#released updates
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
#baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
baseurl=http://vault.centos.org/5.5/updates/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5

#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=addons
#baseurl=http://mirror.centos.org/centos/\$releasever/addons/\$basearch/
baseurl=http://vault.centos.org/5.5/addons/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
#baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
baseurl=http://vault.centos.org/5.5/extras/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/\$releasever/centosplus/\$basearch/
baseurl=http://vault.centos.org/5.5/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5" > /etc/yum.repos.d/CentOS-Base.repo

#/etc/hosts configuration
echo "`ip route get 1 | awk '{print $NF;exit}'` `hostname`" >> /etc/hosts


# Kernel parameters tuning
echo "kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 101365
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 1048576
net.core.rmem_max = 1048576
net.core.wmem_default = 262144
net.core.wmem_max = 262144" >> /etc/sysctl.conf

sysctl -p

/etc/init.d/iptables stop
chkconfig iptables off

# SELinux should be disabled
echo "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config

setenforce 0

groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper oracle

#Specify oracle password
passwd $O_USER <<EOF
$O_PASS
$O_PASS
EOF

echo "export PATH
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1
export ORACLE_SID=ORCL
export ORACLE_TERM=xterm
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

#export LD_LIBRARY_PATH CLASSPATH

if [ $USER = "oracle" ]; then
  if [ $SHELL = "/bin/ksh" ];then
    ulimit -p 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi" >> /home/$O_USER/.bash_profile

#Create directories for software and database
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_BASE $ORACLE_DB
chmod -R 775 $ORACLE_BASE $ORACLE_DB

echo "oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536" >> /etc/security/limits.conf

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


echo "rm -rf $ORACLE_SW_STG
mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
gunzip $ORACLE_SW1
cpio -idmv < $ORACLE_SW2
#runInstaller SILENT
$ORACLE_SW_STG/database/runInstaller -silent -ignoreSysPrereqs \
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
DECLINE_SECURITY_UPDATES=true" > $INST_ORACLE_SW_SHELL



# Adding execute permission to all users
chmod a+x $INST_ORACLE_SW_SHELL

# unzip; runInstaller as oracle
su - $O_USER -c $INST_ORACLE_SW_SHELL
