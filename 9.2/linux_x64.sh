#!/bin/bash

#
# Tested CentOS 4.7
# Database software 9.2.0.4 installation, run as root user
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

ORACLE_SW1=/tmp/amd64_db_9204_Disk1.cpio.gz
ORACLE_SW2=/tmp/amd64_db_9204_Disk2.cpio.gz
ORACLE_SW3=/tmp/amd64_db_9204_Disk3.cpio.gz

echo "# CentOS-Base.repo
#
# CentOS-4 is past End of Life ... use at your own risk
#

[base]
name=CentOS-$releasever - Base
baseurl=http://vault.centos.org/4.7/os/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=1

#released updates 
[update]
name=CentOS-$releasever - Updates
baseurl=http://vault.centos.org/4.7/updates/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=1

#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
baseurl=http://vault.centos.org/4.7/addons/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=1

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://vault.centos.org/4.7/extras/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=1

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=http://vault.centos.org/4.7/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=2

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
baseurl=http://vault.centos.org/4.7/contrib/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4
protect=1
priority=2" > /etc/yum.repos.d/CentOS-Base.repo


#/etc/hosts configuration
echo "`ip route get 1 | awk '{print $NF;exit}'` `hostname`" >> /etc/hosts


# Kernel parameters tuning
echo "kernel.sem = 250 32000 100 128
kernel.shmmax = 2147483648
kernel.shmmni = 128
kernel.shmall = 2097152
kernel.msgmnb = 65536
kernel.msgmni = 2878
fs.file-max = 65536
net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf

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

echo "# Oracle 9i
ORACLE_BASE=$ORACLE_BASE; export ORACLE_BASE
ORACLE_HOME=$ORACLE_HOME; export ORACLE_HOME
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=$ORACLE_HOME/bin:$PATH; export PATH
ORACLE_OWNER=oracle; export ORACLE_OWNER
ORACLE_SID=ORCL; export ORACLE_SID

LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
CLASSPATH=$CLASSPATH:$ORACLE_HOME/network/jlib; export CLASSPATH

LD_ASSUME_KERNEL=2.4.1; export LD_ASSUME_KERNEL
THREADS_FLAG=native; export THREADS_FLAG
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR" >> /home/$O_USER/.bash_profile

#Create directories for software and database
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_BASE $ORACLE_DB
chmod -R 775 $ORACLE_BASE $ORACLE_DB

echo "oracle soft nofile 65536
oracle hard nofile 65536
oracle soft nproc 16384
oracle hard nproc 16384" >> /etc/security/limits.conf

# not required in this version 9.2
# echo "session required pam_limits.so" >> /etc/pam.d/login

# Required packages

yum install compat-gcc-32 -y
yum install compat-gcc-32-c++ -y
yum install compat-libcom_err -y
yum install compat-libcwait -y
yum install compat-libgcc-296 -y
yum install compat-libstdc++-296 -y
yum install compat-libstdc++-33 -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc-common -y
yum install glibc-devel -y
yum install glibc-headers -y
yum install glibc-kernheaders -y
yum install libgcc -y
yum install make -y

yum install binutils-2.15.92.0.2-21 -y
yum install compat-db-4.1.25-9 -y
yum install compat-gcc-32-3.2.3-47.3 -y
yum install compat-gcc-32-c++-3.2.3-47.3 -y
yum install compat-libcom_err-1.0-5 -y
yum install compat-libcwait-2.1-1 -y
yum install compat-libgcc-296-2.96-132.7.2 -y
yum install compat-libstdc++-296-2.96-132.7.2 -y
yum install compat-libstdc++-33-3.2.3-47.3 -y
yum install gcc-3.4.6-3.1 -y
yum install gcc-c++-3.4.6-3.1 -y
yum install glibc-2.3.4-2.25 -y
yum install glibc-common-2.3.4-2.25 -y
yum install glibc-devel-2.3.4-2.25 -y
yum install glibc-headers-2.3.4-2.25 -y
yum install glibc-kernheaders-2.4-9.1.98.EL -y
yum install libgcc-3.4.6-3.1 -y
yum install make-3.80-6.EL4.i386 -y



yum install binutils-2.15.92.0.2-21.x86_64 -y
yum install compat-db-4.1.25-9.i386 -y
yum install compat-db-4.1.25-9.x86_64 -y
yum install compat-gcc-32-3.2.3-47.3.x86_64 -y
yum install compat-gcc-32-c++-3.2.3-47.3.x86_64 -y
yum install compat-libcom_err-1.0-5.i386 -y
yum install compat-libcom_err-1.0-5.x86_64 -y
yum install compat-libgcc-296-2.96-132.7.2.i386 -y
yum install compat-libstdc++-296-2.96-132.7.2.i386 -y
yum install compat-libstdc++-33-3.2.3-47.3.i386 -y
yum install compat-libstdc++-33-3.2.3-47.3.x86_64 -y
yum install gcc-3.4.6-3.1.x86_64 -y
yum install gcc-c++-3.4.6-3.1.x86_64 -y
yum install glibc-2.3.4-2.25.i686 -y
yum install glibc-2.3.4-2.25.x86_64 -y
yum install glibc-common-2.3.4-2.25.x86_64 -y
yum install glibc-devel-2.3.4-2.25.i386 -y
yum install glibc-devel-2.3.4-2.25.x86_64 -y
yum install glibc-headers-2.3.4-2.25.x86_64 -y
yum install glibc-kernheaders-2.4-9.1.98.EL.x86_64 -y
yum install libgcc-3.4.6-3.1.i386 -y
yum install libgcc-3.4.6-3.1.x86_64 -y
yum install make-3.80-6.EL4.x86_64 -y

yum install libaio* -y
yum install openmotif21* -y
yum install xorg-x11-deprecated-libs-devel* -y

echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG

"${ORACLE_SW1%.*}"

gunzip $ORACLE_SW1
gunzip $ORACLE_SW2
gunzip $ORACLE_SW3
cpio -idmv < "${ORACLE_SW1%.*}"
cpio -idmv < "${ORACLE_SW2%.*}"
cpio -idmv < "${ORACLE_SW3%.*}"
" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw

# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# Replace gcc 3.4 with gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc


echo "Now login $O_USER and execute $ORACLE_SW_STG/Disk1/runInstaller..."
echo "You may need to execute xhost + as root if you install from the console"
