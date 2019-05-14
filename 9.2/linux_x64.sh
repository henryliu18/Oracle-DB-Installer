#!/bin/bash

#
# Tested CentOS 4.7
# Database software 9.2.0.4 installation, run as root user
#

# MUST HAVE XMING or directly logged in console GUI as runInstaller will initiate X11 session even
# in SILENT mode

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

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
DISPLAY=:0.0; export DISPLAY

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
UNIX_GROUP_NAME="oinstall"

FROM_LOCATION="$ORACLE_SW_STG/Disk1/response/enterprise.rsp"

FROM_LOCATION_CD_LABEL=<Value Unspecified>

NEXT_SESSION_RESPONSE=<Value Unspecified>

ORACLE_HOME="$ORACLE_HOME"

ORACLE_HOME_NAME="OraHome92"

TOPLEVEL_COMPONENT={"oracle.server","9.2.0.4.0"}

DEINSTALL_LIST={"oracle.server","9.2.0.4.0"}

SHOW_SPLASH_SCREEN=true

SHOW_WELCOME_PAGE=false

SHOW_COMPONENT_LOCATIONS_PAGE=false

SHOW_CUSTOM_TREE_PAGE=false

SHOW_SUMMARY_PAGE=true

SHOW_INSTALL_PROGRESS_PAGE=true

SHOW_REQUIRED_CONFIG_TOOL_PAGE=true

SHOW_OPTIONAL_CONFIG_TOOL_PAGE=true

SHOW_RELEASE_NOTES=true

SHOW_ROOTSH_CONFIRMATION=true

SHOW_END_SESSION_PAGE=true

SHOW_EXIT_CONFIRMATION=true

NEXT_SESSION=true

NEXT_SESSION_ON_FAIL=true

SHOW_DEINSTALL_CONFIRMATION=true

SHOW_DEINSTALL_PROGRESS=true


[oracle.server_9.2.0.4.0]
COMPONENT_LANGUAGES={"en"}

INSTALL_TYPE="EE"

s_serverInstallType=<Value Unspecified>

s_selectedNodes=<Value Unspecified>

s_dbcaProgressOnly=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

s_bundleName=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>

b_launchNETCA=<Value Unspecified>

b_autoStartApache=<Value Unspecified>


[oracle.options_9.2.0.1.0]
s_serverInstallType=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

s_bundleName=<Value Unspecified>


[oracle.options.ops_9.2.0.4.0]
s_serverInstallType=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

s_OPSSelectedNodes=<Value Unspecified>

s_rawDeviceName=<Value Unspecified>


[oracle.cartridges.spatial_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.options.ano_9.2.0.1.0]
s_bundleName=<Value Unspecified>

s_OPSSelectedNodes=<Value Unspecified>


[oracle.options.odm_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rdbms_9.2.0.4.0]
sl_dbaOperGroups=<Value Unspecified>

s_serverInstallType=<Value Unspecified>

s_nameOfBundle=<Value Unspecified>

s_dbcaProgressOnly=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

s_bundleName=<Value Unspecified>

s_OPSSelectedNodes=<Value Unspecified>

s_OPSNodeInfoString=<Value Unspecified>

s_OPSClusterUser=<Value Unspecified>

s_OPSClusterPassword=<Value Unspecified>

s_GlobalDBName=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>

b_lowResource=<Value Unspecified>

b_javaOptionBeingInstalled=<Value Unspecified>


[oracle.networking_9.2.0.1.0]
s_cfgtyperet=<Value Unspecified>

s_bundleName=<Value Unspecified>

b_launchNETCA=<Value Unspecified>


[oracle.networking.netsrv_9.2.0.4.0]
b_net8ServerIsInstalling=<Value Unspecified>


[oracle.assistants.dbma_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

sl_migrateSIDDialogReturn=<Value Unspecified>

s_sidToMigrate=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>

b_noMigration=<Value Unspecified>


[oracle.emprod_9.2.0.1.0]
s_cfgtyperet=<Value Unspecified>

b_launchEMCA=<Value Unspecified>


[oracle.utilities.util_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>


[oracle.options.intermedia.imserver_9.2.0.1.0]
s_bundleName=<Value Unspecified>


[oracle.cartridges.locator_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.isearch.server_9.2.0.4.0]
b_iAS=<Value Unspecified>


[oracle.options.ano.sns_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.java.javavm_9.2.0.4.0]
b_javavmIsInstalling=<Value Unspecified>


[oracle.apache_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

s_oracleSID=<Value Unspecified>

s_jservPort=<Value Unspecified>

s_apacheVersionNumber=<Value Unspecified>

s_apachePortSSL=<Value Unspecified>

s_apachePortNonSSL=<Value Unspecified>

s_apachePort=<Value Unspecified>

s_NLSLANG=<Value Required>

s_LANGUAGE_TERRITORY=<Value Required>

b_autoStartApache=<Value Unspecified>

b_apacheInstalling=<Value Unspecified>

s_topDir=<Value Unspecified>

s_jvm=<Value Unspecified>

ServerRoot=<Value Unspecified>

JDK_HOME=<Value Unspecified>

APACHE_HOME=<Value Unspecified>

s_oracleApacheConfigFile=<Value Unspecified>

s_oracleJservPropertiesFile=<Value Unspecified>


[oracle.cartridges.context_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.soap.jserv_2.0.0.0.0a]
s_soapPort=<Value Unspecified>


[oracle.webdb.modplsql_3.0.9.8.3b]
s_oracleApacheConfigFile=<Value Unspecified>

plsql_cache_dir=<Value Unspecified>

cookie_cache_dir=<Value Unspecified>

APACHE_HOME=<Value Unspecified>


[oracle.networking.netclt_9.2.0.4.0]
s_cfgtyperet=<Value Unspecified>

s_bundleName=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>

b_net8ServerInstalling=<Value Unspecified>

b_launchNETCA=<Value Unspecified>

b_javavmIsInstalling=<Value Unspecified>

b_cmanIsInstalling=<Value Unspecified>

b_anoIsInstalling=<Value Unspecified>

s_netCAInstalledProducts=<Value Unspecified>


[oracle.rdbms.nid_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.emprod.agent_ext.emd_agentext_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.emprod.agent_ext.ows_agentext_9.2.0.1.0]
s_apacheVersionNumber=<Value Unspecified>

b_apacheInstalling=<Value Unspecified>


[oracle.rdbms.ds_9.2.0.1.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.isearch.is_common_9.2.0.4.0]
b_iAS=<Value Unspecified>


[oracle.emprod.oemagent_9.2.0.1.0]
s_cfgtyperet=<Value Unspecified>


[oracle.emprod.oemagent.agentca_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

b_launchAgentCA=<Value Unspecified>


[oracle.assistants.dbca_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

s_serverInstallType=<Value Unspecified>

s_responseFileName=<Value Unspecified>

s_oidPasswd=<Value Unspecified>

s_oidAdmin=<Value Unspecified>

s_instType=<Value Unspecified>

s_globalDBName=<Value Unspecified>

s_dbRetChoice=<Value Unspecified>

s_dbRetChar=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

ps_dbCharSet=<Value Unspecified>

pb_askMountPoint=<Value Unspecified>

b_showCharsetDialog=<Value Unspecified>

b_rdbmsInstalling=<Value Unspecified>

b_noMigration=<Value Unspecified>

b_lowResource=<Value Unspecified>

b_iAS=<Value Unspecified>

b_createStarterDBReturn=<Value Unspecified>

b_configureOid=<Value Unspecified>

CLUSTER_SERVICES=<Value Unspecified>

s_dbcaProgressOnly=<Value Unspecified>

s_cfgname=<Value Unspecified>

pn_softwareSize=<Value Unspecified>

b_passwdDialog=<Value Unspecified>

s_seedLocation=<Value Unspecified>

ps_mountPoint=<Value Unspecified>

pn_databaseSize=<Value Unspecified>

s_templateValue=<Value Unspecified>

s_dbSid=<Value Unspecified>

s_mountPoint=<Value Unspecified>


[oracle.networking.netca_9.2.0.4.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

s_responseFileName=<Value Unspecified>

s_netCAInstalledProtocols=<Value Unspecified>

s_netCAInstalledProducts=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>

b_launchNETCA=<Value Unspecified>


[oracle.bc4j_9.0.2.692.1]
s_oracleJservPropertiesFile=<Value Unspecified>

s_oc4jdeployini=<Value Unspecified>

APACHE_HOME=<Value Unspecified>


[oracle.rdbms.ovm_9.2.0.1.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.soap.srv_2.0.0.0.0a]
b_serverInstalled=<Value Unspecified>


[oracle.soap.cli_2.0.0.0.0a]
b_serverInstalled=<Value Unspecified>

s_hostPort=<Value Unspecified>


[oracle.jdk_1.4.2.0.0]
s_jdkVersion=<Value Unspecified>

isNT=<Value Unspecified>

JRE_LIBHOME=<Value Unspecified>

JRE_LIB=<Value Unspecified>

JRE_BIN=<Value Unspecified>

JDK_HOME=<Value Unspecified>


[oracle.java.j2ee.core_9.2.0.1.0]
JDK_HOME=<Value Unspecified>


[oracle.rdbms.common_schema_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.rsf_9.2.0.1.0]
s_serverInstallType=<Value Unspecified>

s_bundleName=<Value Unspecified>


[oracle.options.ops.opsca_9.2.0.1.0]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

s_serverInstallType=<Value Unspecified>

s_cfgtyperet=<Value Unspecified>


[oracle.rsf.nlsrtl_rsf_9.2.0.4.0]
s_serverInstallType=<Value Unspecified>


[oracle.options.ops.pfs_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.oid.tools_9.2.0.1.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rsf.ssl_rsf_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.rsf.rdbms_rsf_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.rsf.xdk_rsf_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.install.instcommon_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.doc.unixdoc_9.2.0.1.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rsf.hybrid_9.2.0.1.0]
s_bundleName=<Value Unspecified>


[oracle.apache.jserv_1.1.0.0.0g]
s_soapPort=<Value Unspecified>

s_jservPort=<Value Unspecified>

s_LANGUAGE_TERRITORY=<Value Required>

b_autoPortDetect=<Value Unspecified>

s_topDir=<Value Unspecified>

s_jvm=<Value Unspecified>

APACHE_HOME=<Value Unspecified>

s_oracleApacheConfigFile=<Value Unspecified>

s_oracleJservPropertiesFile=<Value Unspecified>


[oracle.apache.jsdk_2.0.0.0.0d]
s_topDir=<Value Unspecified>


[oracle.rsf.net_rsf_9.2.0.4.0]
s_bundleName=<Value Unspecified>


[oracle.ocs4j_2.1.0.0.0a]
s_cachePort=<Value Unspecified>


[oracle.rdbms.aqapi_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.java.sqlj.sqljruntime_9.2.0.4.0]
s_OPSSelectedNodes=<Value Unspecified>


[oracle.apache.apache_1.3.22.0.0a]
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

sl_OHs=<Value Unspecified>

s_apacheServerAppendText=<Value Required>

s_apachePortSSL=<Value Unspecified>

s_apachePortNonSSL=<Value Unspecified>

s_apachePort=<Value Unspecified>

s_NLSLANG=<Value Required>

b_autoStartApache=<Value Unspecified>

b_autoPortDetect=<Value Unspecified>

s_topDir=<Value Unspecified>

ServerRoot=<Value Unspecified>

APACHE_HOME=<Value Unspecified>


[oracle.swd.jre_1.4.2.0.0]
PROD_HOME=<Value Unspecified>

s_OPSSelectedNodes=<Value Unspecified>" > $SCRIPT_DIR/enterprise.rsp

# xhost +
xhost +

echo "$ORACLE_SW_STG/Disk1/runInstaller -waitforcompletion -responseFile $SCRIPT_DIR/sw2.rsp -silent" > ${SCRIPT_DIR}/inst_ora_sw2
# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw2
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw2

# root.sh as root
$ORACLE_HOME/root.sh
