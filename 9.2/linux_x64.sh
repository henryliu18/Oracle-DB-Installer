#!/bin/bash

#
# Tested CentOS 4.7
# Database software 9.2.0.4 installation, run as root user
#

# MUST HAVE XMING or directly logged in console GUI as runInstaller will initiate X11 session even
# in SILENT mode
# todo -> software only still not working to be fixed

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

# Source function.sh
source ../function.sh
num_lines=$( lines_in_file /etc/passwd )
echo The file $1 has $num_lines lines in it.
exit 1

# XMING checks
export DISPLAY=$XMING_IP:0.0
(xdpyinfo>/tmp/xtest 2>&1) &
my_pid=$!

i=0
while   ps | grep $my_pid>/dev/null     # might also need  | grep -v grep  here
do
    i=$((i+1))
    #echo $my_pid is still in the ps output. Must still be running "$i".
    sleep 2
    if [ $i -eq 3 ]; then
      #echo "timeout killing $my_pid"
      timeout=yes
      kill -9 $my_pid
    fi
done

if [ "$timeout" = "yes" ]; then
  echo "exiting, check XMING or firewall or X0.hosts file"
  exit 1
else
  value=$( grep -ic "refused" /tmp/xtest )
  if [ "$value" -eq 1 ]; then
    echo "exiting, check XMING or firewall or X0.hosts file"
    exit 1
  else
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
echo "# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - SELinux is fully disabled.
#SELINUX=enforcing
SELINUX=disabled
# SELINUXTYPE= type of policy in use. Possible values are:
#       targeted - Only targeted network daemons are protected.
#       strict - Full SELinux protection.
SELINUXTYPE=targeted" > /etc/selinux/config

setenforce 0

groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper $O_USER

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
ORACLE_OWNER=$O_USER; export ORACLE_OWNER
ORACLE_SID=$CDB; export ORACLE_SID

LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
CLASSPATH=$CLASSPATH:$ORACLE_HOME/network/jlib; export CLASSPATH

LD_ASSUME_KERNEL=2.4.1; export LD_ASSUME_KERNEL
THREADS_FLAG=native; export THREADS_FLAG
TMP=/tmp; export TMP
TMPDIR=\$TMP; export TMPDIR" >> /home/$O_USER/.bash_profile

#Create directories for software and database
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_BASE $ORACLE_DB
chmod -R 775 $ORACLE_BASE $ORACLE_DB

echo "$O_USER soft nofile 65536
$O_USER hard nofile 65536
$O_USER soft nproc 16384
$O_USER hard nproc 16384" >> /etc/security/limits.conf

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

chown $O_USER:oinstall $ORACLE_SW1
chown $O_USER:oinstall $ORACLE_SW2
chown $O_USER:oinstall $ORACLE_SW3

echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG

if [ -f "${ORACLE_SW1%.*}" ]; then 
  cpio -idmv < "${ORACLE_SW1%.*}";
else
  gunzip $ORACLE_SW1
  cpio -idmv < "${ORACLE_SW1%.*}";
fi
if [ -f "${ORACLE_SW2%.*}" ]; then 
  cpio -idmv < "${ORACLE_SW2%.*}";
else
  gunzip $ORACLE_SW2
  cpio -idmv < "${ORACLE_SW2%.*}";
fi
if [ -f "${ORACLE_SW3%.*}" ]; then 
  cpio -idmv < "${ORACLE_SW3%.*}";
else
  gunzip $ORACLE_SW3
  cpio -idmv < "${ORACLE_SW3%.*}";
fi
" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# Replace gcc 3.4 with gcc 3.2 - root task
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc

# create /etc/oraInst.loc as root
echo "inventory_loc=$ORACLE_BASE/oraInventory
inst_group=oinstall" > /etc/oraInst.loc

# responseFile creation
echo "[General]
RESPONSEFILE_VERSION=1.7.0

[SESSION]
UNIX_GROUP_NAME=\"oinstall\"
FROM_LOCATION="$ORACLE_SW_STG/Disk1/stage/products.jar"
ORACLE_HOME=$ORACLE_HOME
ORACLE_HOME_NAME=\"OraHome92\"
TOPLEVEL_COMPONENT={\"oracle.server\",\"9.2.0.4.0\"}
NEXT_SESSION=true
COMPONENT_LANGUAGES={"en"}
INSTALL_TYPE="EE"
s_cfgtyperet=\"Software Only\"

[oracle.assistants.dbca_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS={\"\"}

[oracle.apache_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS={\"\"}

[oracle.networking.netca_9.2.0.4.0]
OPTIONAL_CONFIG_TOOLS={\"\"}

" > $SCRIPT_DIR/enterprise.rsp

# xhost +

echo "$ORACLE_SW_STG/Disk1/runInstaller -noconsole -silent -force -waitforcompletion -responseFile $SCRIPT_DIR/enterprise.rsp" > ${SCRIPT_DIR}/inst_ora_sw2
# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw2
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw2

# log checker of oracle installer
until [ "$OUTPUT" = "The installation of Oracle9i Database was successful." ]; do
  OUTPUT=`grep 'The installation of Oracle9i Database was successful.' $ORACLE_BASE/oraInventory/logs/silentInstall*.log`
  sleep 5
done

# root.sh as root
$ORACLE_HOME/root.sh<<EOF
/usr/local/bin
EOF

# Revert gcc 3.4 from gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc

# cleanup
rm -f ${SCRIPT_DIR}/inst_ora_sw
rm -f ${SCRIPT_DIR}/inst_ora_sw2
rm -f ${SCRIPT_DIR}/enterprise.rsp
rm -rf $ORACLE_SW_STG
fi
fi
