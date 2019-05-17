#!/bin/bash

#
# Tested Redhat 6.2 (Zoot)
#  Linux/Linux 2.2
#  1 GB memory
#  8 GB disk
#  Network -> Bridge Adapter (VirtualBox)
#
#  Type 'text' for text mode installation
#  Install Custom
#  X Window System
#  GNOME
#  Networked Worksatation
#  Anonymous FTP Server
#  Network Management Workstation
#  Development
#  Kernel Development
#  Utilities
#  Generic SVGA
#
#

# Checklist
# [Redhat 6.2 (zoot)] - mount iso to /mnt
# [Oracle 8.1.7] - /tmp/linux81701.tar.bz2
# [Sun JDK 1.2.2] for linux - /tmp/jdk-1_2_2_017-linux-i586.tar.gz
# [xming] will be serving runInstaller as xwindow server, oracle server will be xwindow client
#  Install xming on your workstation
#  Make sure oracle server ip is added to x0.hosts under xming directory (e.g. C:\Program Files (x86)\Xming\X0.hosts)
#  Turn off Windows firewall on your workstation to let xming traffic pass through
#  Make sure xming is launched on your workstation
#  Make sure XMING_IP is set to your workstation ip
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi


# Execute below command to allow root ftp or simply remove "root" from /etc/ftpusers
cp /etc/ftpusers /etc/ftpusers.orig
sed -e '/root/s/^/#/g' /etc/ftpusers.orig > /etc/ftpusers

# Execute below command to allow root telnet or simply comment out "auth       required    /lib/security/pam_securetty.so" from /etc/pam.d/login
cp /etc/pam.d/login /etc/pam.d/login.orig
sed -e '/pam_securetty.so/s/^/#/g' /etc/pam.d/login.orig > /etc/pam.d/login

# Only if telnetd and ftpd not up
rpm -ivh /mnt/RedHat/RPMS/telnet-server-0.16-6.i386.rpm
rpm -ivh /mnt/RedHat/RPMS/wu-ftpd-2.6.0-3.i386.rpm
rpm -ivh /mnt/RedHat/RPMS/inetd-0.16-4.i386.rpm
/etc/rc.d/init.d/inet start
chkconfig inet on

#
# Database software installation, run as root user
#

JAVA_HOME=/usr/local/java
JAVA_SW=/tmp/jdk-1_2_2_017-linux-i586.tar.gz
ORACLE_SW1=/tmp/linux81701.tar.bz2
XMING_IP=192.168.1.16

# user and groups creation
groupadd -g 54321 oinstall
groupadd -g 54322 dba
useradd -u 54321 -g oinstall -G dba $O_USER

#Specify oracle password
passwd $O_USER <<EOF
$O_PASS
$O_PASS
EOF

# Only if firewall is on
/etc/rc.d/init.d/ipchains stop
chkconfig ipchains off

cd /usr/local
tar xvfz $JAVA_SW
ln -s jdk1.2.2 java

echo "unset USERNAME
ORACLE_BASE=$ORACLE_BASE
JAVA_HOME=$JAVA_HOME
LC_ALL=C
LANG=C
NLS_LANG=American_America.UTF8
ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
export ORACLE_BASE JAVA_HOME LC_ALL LANG NLS_LANG ORA_NLS33
ORACLE_HOME=$ORACLE_HOME
PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH
export ORACLE_HOME PATH" >> /home/$O_USER/.bashrc

#Create directories for software and database
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_BASE $ORACLE_DB
chmod -R 775 $ORACLE_BASE $ORACLE_DB

#echo "oracle soft nofile 65536
#oracle hard nofile 65536
#oracle soft nproc 16384
#oracle hard nproc 16384" >> /etc/security/limits.conf


# Required packages
cd /mnt/cdrom/RedHat/RPMS/
rpm -ivh \
XFree86-3.3.6-20.i386.rpm \
XFree86-libs-3.3.6-20.i386.rpm \
XFree86-xfs-3.3.6-20.i386.rpm \
make-3.78.1-4.i386.rpm \
egcs-1.1.2-30.i386.rpm \
cpp-1.1.2-30.i386.rpm \
glibc-devel-2.1.3-15.i386.rpm \
kernel-headers-2.2.14-5.0.i386.rpm

# Making shell script for oracle installer
echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
bunzip2 -cd $ORACLE_SW1 | tar xvf -
export DISPLAY=$XMING_IP:0.0
$ORACLE_SW_STG/Disk1/runInstaller" > $SCRIPT_DIR/inst_ora_sw

# Adding execute permission to all users
chmod a+x $SCRIPT_DIR/inst_ora_sw

# unzip; set DISPLAY; runInstaller as oracle
su - $O_USER -c $SCRIPT_DIR/inst_ora_sw
