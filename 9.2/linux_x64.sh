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
echo "####################################################################
## Copyright(c) Oracle Corporation 1998,2002. All rights reserved.##
##                                                                ##
## Specify values for the variables listed below to customize     ##
## your installation.                                             ##
##                                                                ##
## Each variable is associated with a comment. The comment        ##
## identifies the variable type.                                  ##
##                                                                ##
## Please specify the values in the following format:             ##
##                                                                ##
##         Type         Example                                   ##
##         String       "Sample Value"                            ##
##         Boolean      True or False                             ##
##         Number       1000                                      ##
##         StringList   {"String value 1","String Value 2"}       ##
##                                                                ##
## The values that are given as <Value Required> need to be       ##
## specified for a silent installation to be successful.          ##
##                                                                ##
##                                                                ##
## This response file is generated by Oracle Software             ##
## Packager.                                                      ##
####################################################################

[General]
RESPONSEFILE_VERSION=1.7.0


[SESSION]
#Parameter: UNIX_GROUP_NAME
#Type: String
#Description: Unix group to be set for the inventory directory. Valid only in Unix platforms.
#Example : UNIX_GROUP_NAME = "install"
UNIX_GROUP_NAME="oinstall"

#Parameter: FROM_LOCATION
#Type: String
#Description: Complete path of the products.jar.
#Example : FROM_LOCATION = "../stage/products.jar"
FROM_LOCATION="$ORACLE_SW_STG/Disk1/stage/products.jar"

#Parameter: FROM_LOCATION_CD_LABEL
#Type: String
#Description: This variable should only be used in multi-CD installations. It includes the label of the Compact Disk where the file "products.jar" exists. The label can be found in the file "disk.label" in the same directory as products.jar.
#Example : FROM_LOCATION_CD_LABEL = "CD Label"
FROM_LOCATION_CD_LABEL=<Value Unspecified>

#Parameter: NEXT_SESSION_RESPONSE
#Type: String
#Description: Optionally specifies the full path of next session's response file. If only a file name is specified, the response file is retrieved from <TEMP>/oraInstall directory. This variable is only active if NEXT_SESSION is set to true.
#Example : NEXT_SESSION_RESPONSE = "nextinstall.rsp"
NEXT_SESSION_RESPONSE=<Value Unspecified>

#Parameter: ORACLE_HOME
#Type: String
#Description: Complete Location of the Oracle Home.
#Example : ORACLE_HOME = "C:\OHOME1"
ORACLE_HOME="$ORACLE_HOME"

#Parameter: ORACLE_HOME_NAME
#Type: String
#Description: Oracle Home Name. Used in creating folders, services.
#Example : ORACLE_HOME_NAME = "OHOME1"
ORACLE_HOME_NAME="OraHome92"

#Parameter: TOPLEVEL_COMPONENT
#Type: StringList
#Description: The Toplevel component that has to be installed in the current session.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name, Version : External name. Please use the internal name and version while specifying the value.
#    oracle.server, 9.2.0.4.0 : Oracle9i Database 9.2.0.4.0 
#    oracle.client, 9.2.0.4.0 : Oracle9i Client 9.2.0.4.0 
#    oracle.infrastructure, 9.2.0.4.0 : Oracle9i Management and Integration 9.2.0.4.0 
#    oracle.options.ops.clustermgr, 9.2.0.4.0 : Oracle Cluster Manager 9.2.0.4.0 
#Example : TOPLEVEL_COMPONENT = {"oracle.server","9.2.0.4.0"}
TOPLEVEL_COMPONENT={"oracle.server","9.2.0.4.0"}

#Parameter: DEINSTALL_LIST
#Type: StringList
#Description: List of components to be deinstalled during a deinstall session.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name, Version : External name. Please use the internal name and version while specifying the value.
#    oracle.server, 9.2.0.4.0 : Oracle9i Database 9.2.0.4.0 
#    oracle.client, 9.2.0.4.0 : Oracle9i Client 9.2.0.4.0 
#    oracle.infrastructure, 9.2.0.4.0 : Oracle9i Management and Integration 9.2.0.4.0 
#    oracle.options.ops.clustermgr, 9.2.0.4.0 : Oracle Cluster Manager 9.2.0.4.0 
#Example : DEINSTALL_LIST = {"oracle.server","9.2.0.4.0"}
DEINSTALL_LIST={"oracle.server","9.2.0.4.0"}

#Parameter: SHOW_SPLASH_SCREEN
#Type: Boolean
#Description: Set to true if the initial splash screen in the installer needs to be shown.
#Example : SHOW_SPLASH_SCREEN = true
SHOW_SPLASH_SCREEN=true

#Parameter: SHOW_WELCOME_PAGE
#Type: Boolean
#Description: Set to true if the Welcome page in the installer needs to be shown.
#Example : SHOW_WELCOME_PAGE = false
SHOW_WELCOME_PAGE=false

#Parameter: SHOW_COMPONENT_LOCATIONS_PAGE
#Type: Boolean
#Description: Set to true if the component locations page in the installer needs to be shown.
#This page only appears if there are products whose installed directory can be changed.
#If you set this to false you will prevent the user from being able to specify alternate directories.
#Example : SHOW_COMPONENT_LOCATIONS_PAGE = false
SHOW_COMPONENT_LOCATIONS_PAGE=false

#Parameter: SHOW_CUSTOM_TREE_PAGE
#Type: Boolean
#Description: Set to true if the custom tree page in the installer needs to be shown.
#In this page dependencies can be selected or unselected. This page appears only in a custom install type.
#Example : SHOW_CUSTOM_TREE_PAGE = false
SHOW_CUSTOM_TREE_PAGE=false

#Parameter: SHOW_SUMMARY_PAGE
#Type: Boolean
#Description: Set to true if the summary page in the installer needs to be shown.
#The summary page shows the list of components that will be installed in this session. 
#Example : SHOW_SUMMARY_PAGE = true
SHOW_SUMMARY_PAGE=true

#Parameter: SHOW_INSTALL_PROGRESS_PAGE
#Type: Boolean
#Description: Set to true if the install progress page in the installer needs to be shown.
#This page shows the current status in the installation. The current status includes which product is being installed, which file is being copied.
#Example : SHOW_INSTALL_PROGRESS_PAGE = true
SHOW_INSTALL_PROGRESS_PAGE=true

#Parameter: SHOW_REQUIRED_CONFIG_TOOL_PAGE
#Type: Boolean
#Description: Set to true if the required config tools page in the installer needs to be shown.
#This page shows the list of required configuration tools that are part of this installation.
#It shows the status of each tool, including any failures with detailed information on why the tool has failed.
#Example : SHOW_REQUIRED_CONFIG_TOOL_PAGE = true
SHOW_REQUIRED_CONFIG_TOOL_PAGE=true

#Parameter: SHOW_OPTIONAL_CONFIG_TOOL_PAGE
#Type: Boolean
#Description: Set to true if the optional config tools page in the installer needs to be shown.
#This page shows the list of optional configuration tools that are part of this installation and are configured to launch automatically.
#It shows the status of each tool, including any failures with detailed information on why the tool has failed.
#Example : SHOW_OPTIONAL_CONFIG_TOOL_PAGE = true
SHOW_OPTIONAL_CONFIG_TOOL_PAGE=true

#Parameter: SHOW_RELEASE_NOTES
#Type: Boolean
#Description: Set to true if the release notes of this installation need to be shown at the end of installation.
#This dialog is launchable from the End of Installation page and shows the list of release notes available for the products just installed.
# This also requires the variable SHOW_END_SESSION_PAGE variable to be set to true.
#Example : SHOW_RELEASE_NOTES = true
SHOW_RELEASE_NOTES=true

#Parameter: SHOW_ROOTSH_CONFIRMATION
#Type: Boolean
#Description: Set to true if the Confirmation dialog asking to run the root.sh script in the installer needs to be shown.
#Valid only in Unix platforms.
#Example : SHOW_ROOTSH_CONFIRMATION = true
SHOW_ROOTSH_CONFIRMATION=true

#Parameter: SHOW_END_SESSION_PAGE
#Type: Boolean
#Description: Set to true if the end of session page in the installer needs to be shown.
#This page shows if the installation is successful or not.
#Example : SHOW_END_SESSION_PAGE = true
SHOW_END_SESSION_PAGE=true

#Parameter: SHOW_EXIT_CONFIRMATION
#Type: Boolean
#Description: Set to true if the confirmation when exiting the installer needs to be shown.
#Example : SHOW_EXIT_CONFIRMATION = true
SHOW_EXIT_CONFIRMATION=true

#Parameter: NEXT_SESSION
#Type: Boolean
#Description: Set to true to allow users to go back to the File Locations page for another installation. This flag also needs to be set to true in order to process another response file (see NEXT_SESSION_RESPONSE).
#Example : NEXT_SESSION = true
NEXT_SESSION=true

#Parameter: NEXT_SESSION_ON_FAIL
#Type: Boolean
#Description: Set to true to allow users to invoke another session even if current install session has failed. This flag is only relevant if NEXT_SESSION is set to true.
#Example : NEXT_SESSION_ON_FAIL = true
NEXT_SESSION_ON_FAIL=true

#Parameter: SHOW_DEINSTALL_CONFIRMATION
#Type: Boolean
#Description: Set to true if deinstall confimation is needed during a deinstall session.
#Example : SHOW_DEINSTALL_CONFIRMATION = true
SHOW_DEINSTALL_CONFIRMATION=true

#Parameter: SHOW_DEINSTALL_PROGRESS
#Type: Boolean
#Description: Set to true if deinstall progress is needed during a deinstall session.
#Example : SHOW_DEINSTALL_PROGRESS = true
SHOW_DEINSTALL_PROGRESS=true


[oracle.server_9.2.0.4.0]
#Parameter: COMPONENT_LANGUAGES
#Type: StringList
#Description: Languages in which the components will be installed.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    en,   : English
#    fr,   : French
#    ar,   : Arabic
#    bn,   : Bengali
#    pt_BR,   : Brazilian Portuguese
#    bg,   : Bulgarian
#    fr_CA,   : Canadian French
#    ca,   : Catalan
#    hr,   : Croatian
#    cs,   : Czech
#    da,   : Danish
#    nl,   : Dutch
#    ar_EG,   : Egyptian
#    en_GB,   : English (United Kingdom)
#    et,   : Estonian
#    fi,   : Finnish
#    de,   : German
#    el,   : Greek
#    iw,   : Hebrew
#    hu,   : Hungarian
#    is,   : Icelandic
#    in,   : Indonesian
#    it,   : Italian
#    ja,   : Japanese
#    ko,   : Korean
#    es,   : Latin American Spanish
#    lv,   : Latvian
#    lt,   : Lithuanian
#    ms,   : Malay
#    es_MX,   : Mexican Spanish
#    no,   : Norwegian
#    pl,   : Polish
#    pt,   : Portuguese
#    ro,   : Romanian
#    ru,   : Russian
#    zh_CN,   : Simplified Chinese
#    sk,   : Slovak
#    sl,   : Slovenian
#    es_ES,   : Spanish
#    sv,   : Swedish
#    th,   : Thai
#    zh_TW,   : Traditional Chinese
#    tr,   : Turkish
#    uk,   : Ukrainian
#    vi,   : Vietnamese
#Example : COMPONENT_LANGUAGES = {"en"}
COMPONENT_LANGUAGES={"en"}

#Parameter: INSTALL_TYPE
#Type: String
#Description: Installation type of the component.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    EE,   : Enterprise Edition
#    SE,   : Standard Edition
#    Custom,   : Custom
#Example : INSTALL_TYPE = "EE"
INSTALL_TYPE="EE"

#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_selectedNodes
#Type: String
s_selectedNodes=<Value Unspecified>

#Parameter: s_dbcaProgressOnly
#Type: String
s_dbcaProgressOnly=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>

#Parameter: b_launchNETCA
#Type: Boolean
b_launchNETCA=<Value Unspecified>

#Parameter: b_autoStartApache
#Type: Boolean
b_autoStartApache=<Value Unspecified>


[oracle.options_9.2.0.1.0]
#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.options.ops_9.2.0.4.0]
#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>

#Parameter: s_rawDeviceName
#Type: String
s_rawDeviceName=<Value Unspecified>


[oracle.cartridges.spatial_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.options.ano_9.2.0.1.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>

#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.options.odm_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rdbms_9.2.0.4.0]
#Parameter: sl_dbaOperGroups
#Type: StringList
sl_dbaOperGroups=<Value Unspecified>

#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_nameOfBundle
#Type: String
s_nameOfBundle=<Value Unspecified>

#Parameter: s_dbcaProgressOnly
#Type: String
s_dbcaProgressOnly=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>

#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>

#Parameter: s_OPSNodeInfoString
#Type: String
s_OPSNodeInfoString=<Value Unspecified>

#Parameter: s_OPSClusterUser
#Type: String
s_OPSClusterUser=<Value Unspecified>

#Parameter: s_OPSClusterPassword
#Type: String
s_OPSClusterPassword=<Value Unspecified>

#Parameter: s_GlobalDBName
#Type: String
s_GlobalDBName=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>

#Parameter: b_lowResource
#Type: Boolean
b_lowResource=<Value Unspecified>

#Parameter: b_javaOptionBeingInstalled
#Type: Boolean
b_javaOptionBeingInstalled=<Value Unspecified>


[oracle.networking_9.2.0.1.0]
#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>

#Parameter: b_launchNETCA
#Type: Boolean
b_launchNETCA=<Value Unspecified>


[oracle.networking.netsrv_9.2.0.4.0]
#Parameter: b_net8ServerIsInstalling
#Type: Boolean
b_net8ServerIsInstalling=<Value Unspecified>


[oracle.assistants.dbma_9.2.0.1.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    dbma,   : Database Upgrade Assistant
#Example : OPTIONAL_CONFIG_TOOLS = {"dbma"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: sl_migrateSIDDialogReturn
#Type: StringList
sl_migrateSIDDialogReturn=<Value Unspecified>

#Parameter: s_sidToMigrate
#Type: String
s_sidToMigrate=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>

#Parameter: b_noMigration
#Type: Boolean
b_noMigration=<Value Unspecified>


[oracle.emprod_9.2.0.1.0]
#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: b_launchEMCA
#Type: Boolean
b_launchEMCA=<Value Unspecified>


[oracle.utilities.util_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>


[oracle.options.intermedia.imserver_9.2.0.1.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.cartridges.locator_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.isearch.server_9.2.0.4.0]
#Parameter: b_iAS
#Type: Boolean
b_iAS=<Value Unspecified>


[oracle.options.ano.sns_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.java.javavm_9.2.0.4.0]
#Parameter: b_javavmIsInstalling
#Type: Boolean
b_javavmIsInstalling=<Value Unspecified>


[oracle.apache_9.2.0.1.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    configtool1,   : Starting HTTP Server
#    configtool2,   : Starting Oracle HTTP service
#Example : OPTIONAL_CONFIG_TOOLS = {"configtool1"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: s_oracleSID
#Type: String
#Description: Oracle SID that can be passed in from top level install component.
s_oracleSID=<Value Unspecified>

#Parameter: s_jservPort
#Type: String
#Description: The port Apache JServ listens to
s_jservPort=<Value Unspecified>

#Parameter: s_apacheVersionNumber
#Type: String
#Description: version number of apache passed to oem agent
s_apacheVersionNumber=<Value Unspecified>

#Parameter: s_apachePortSSL
#Type: String
#Description: Apache SSL port used when starting in ssl mode.  Default 443
s_apachePortSSL=<Value Unspecified>

#Parameter: s_apachePortNonSSL
#Type: String
#Description: Port number that apache uses when starting in non-ssl mode
s_apachePortNonSSL=<Value Unspecified>

#Parameter: s_apachePort
#Type: String
#Description: Port number that apache uses when starting in ssl mode
s_apachePort=<Value Unspecified>

#Parameter: s_NLSLANG
#Type: String
#Description: String to hold the NLS LANG value determined by GetNlsLangWindows q
#uery.
s_NLSLANG=<Value Required>

#Parameter: s_LANGUAGE_TERRITORY
#Type: String
#Description: Substring of s_NLSLANG
s_LANGUAGE_TERRITORY=<Value Required>

#Parameter: b_autoStartApache
#Type: Boolean
#Description: Set to false if you do not want apache to start after installation
b_autoStartApache=<Value Unspecified>

#Parameter: b_apacheInstalling
#Type: Boolean
#Description: Set to true and passed to oem agent
b_apacheInstalling=<Value Unspecified>

#Parameter: s_topDir
#Type: String
#Description: APACHE_TOP directory for Apache Web Server
s_topDir=<Value Unspecified>

#Parameter: s_jvm
#Type: String
#Description: Path to the Java Virtual Machine
s_jvm=<Value Unspecified>

#Parameter: ServerRoot
#Type: String
#Description: Apache Server root directory
ServerRoot=<Value Unspecified>

#Parameter: JDK_HOME
#Type: String
#Description: JDK home location
JDK_HOME=<Value Unspecified>

#Parameter: APACHE_HOME
#Type: String
#Description: Main apache directory off of ORACLE_HOME where all components live under  i.e. ORACLE_HOME/Apache
APACHE_HOME=<Value Unspecified>

#Parameter: s_oracleApacheConfigFile
#Type: String
#Description: Location of oracle_apache.conf file to be passed to all modules that need to include there conf file.
s_oracleApacheConfigFile=<Value Unspecified>

#Parameter: s_oracleJservPropertiesFile
#Type: String
#Description: Location of the Jserv.properties file
s_oracleJservPropertiesFile=<Value Unspecified>


[oracle.cartridges.context_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.soap.jserv_2.0.0.0.0a]
#Parameter: s_soapPort
#Type: String
#Description: The port that SOAP/JServ listens to
s_soapPort=<Value Unspecified>


[oracle.webdb.modplsql_3.0.9.8.3b]
#Parameter: s_oracleApacheConfigFile
#Type: String
#Description: The Apache config file oracle_apache.conf will be passed with this variable.
s_oracleApacheConfigFile=<Value Unspecified>

#Parameter: plsql_cache_dir
#Type: String
#Description: This is the location of the cache directory.
plsql_cache_dir=<Value Unspecified>

#Parameter: cookie_cache_dir
#Type: String
#Description: This variable holds the value of the cookie cache directory.
cookie_cache_dir=<Value Unspecified>

#Parameter: APACHE_HOME
#Type: String
#Description: The directory location where Apache is installed.
APACHE_HOME=<Value Unspecified>


[oracle.networking.netclt_9.2.0.4.0]
#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>

#Parameter: b_net8ServerInstalling
#Type: Boolean
b_net8ServerInstalling=<Value Unspecified>

#Parameter: b_launchNETCA
#Type: Boolean
b_launchNETCA=<Value Unspecified>

#Parameter: b_javavmIsInstalling
#Type: Boolean
b_javavmIsInstalling=<Value Unspecified>

#Parameter: b_cmanIsInstalling
#Type: Boolean
b_cmanIsInstalling=<Value Unspecified>

#Parameter: b_anoIsInstalling
#Type: Boolean
b_anoIsInstalling=<Value Unspecified>

#Parameter: s_netCAInstalledProducts
#Type: String
s_netCAInstalledProducts=<Value Unspecified>


[oracle.rdbms.nid_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.emprod.agent_ext.emd_agentext_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.emprod.agent_ext.ows_agentext_9.2.0.1.0]
#Parameter: s_apacheVersionNumber
#Type: String
s_apacheVersionNumber=<Value Unspecified>

#Parameter: b_apacheInstalling
#Type: Boolean
b_apacheInstalling=<Value Unspecified>


[oracle.rdbms.ds_9.2.0.1.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.isearch.is_common_9.2.0.4.0]
#Parameter: b_iAS
#Type: Boolean
b_iAS=<Value Unspecified>


[oracle.emprod.oemagent_9.2.0.1.0]
#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>


[oracle.emprod.oemagent.agentca_9.2.0.1.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    agentca,   : Agent Configuration Assistant
#Example : OPTIONAL_CONFIG_TOOLS = {"agentca"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: b_launchAgentCA
#Type: Boolean
b_launchAgentCA=<Value Unspecified>


[oracle.assistants.dbca_9.2.0.1.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    dbca,   : Oracle Database Configuration Assistant
#Example : OPTIONAL_CONFIG_TOOLS = {"dbca"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_responseFileName
#Type: String
s_responseFileName=<Value Unspecified>

#Parameter: s_oidPasswd
#Type: String
s_oidPasswd=<Value Unspecified>

#Parameter: s_oidAdmin
#Type: String
s_oidAdmin=<Value Unspecified>

#Parameter: s_instType
#Type: String
s_instType=<Value Unspecified>

#Parameter: s_globalDBName
#Type: String
s_globalDBName=<Value Unspecified>

#Parameter: s_dbRetChoice
#Type: String
s_dbRetChoice=<Value Unspecified>

#Parameter: s_dbRetChar
#Type: String
s_dbRetChar=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: ps_dbCharSet
#Type: String
ps_dbCharSet=<Value Unspecified>

#Parameter: pb_askMountPoint
#Type: Boolean
pb_askMountPoint=<Value Unspecified>

#Parameter: b_showCharsetDialog
#Type: Boolean
b_showCharsetDialog=<Value Unspecified>

#Parameter: b_rdbmsInstalling
#Type: Boolean
b_rdbmsInstalling=<Value Unspecified>

#Parameter: b_noMigration
#Type: Boolean
b_noMigration=<Value Unspecified>

#Parameter: b_lowResource
#Type: Boolean
b_lowResource=<Value Unspecified>

#Parameter: b_iAS
#Type: Boolean
b_iAS=<Value Unspecified>

#Parameter: b_createStarterDBReturn
#Type: Boolean
b_createStarterDBReturn=<Value Unspecified>

#Parameter: b_configureOid
#Type: Boolean
b_configureOid=<Value Unspecified>

#Parameter: CLUSTER_SERVICES
#Type: String
CLUSTER_SERVICES=<Value Unspecified>

#Parameter: s_dbcaProgressOnly
#Type: String
s_dbcaProgressOnly=<Value Unspecified>

#Parameter: s_cfgname
#Type: String
s_cfgname=<Value Unspecified>

#Parameter: pn_softwareSize
#Type: Number
pn_softwareSize=<Value Unspecified>

#Parameter: b_passwdDialog
#Type: Boolean
b_passwdDialog=<Value Unspecified>

#Parameter: s_seedLocation
#Type: String
s_seedLocation=<Value Unspecified>

#Parameter: ps_mountPoint
#Type: String
ps_mountPoint=<Value Unspecified>

#Parameter: pn_databaseSize
#Type: Number
pn_databaseSize=<Value Unspecified>

#Parameter: s_templateValue
#Type: String
s_templateValue=<Value Unspecified>

#Parameter: s_dbSid
#Type: String
s_dbSid=<Value Unspecified>

#Parameter: s_mountPoint
#Type: String
s_mountPoint=<Value Unspecified>


[oracle.networking.netca_9.2.0.4.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    netca,   : Oracle Net Configuration Assistant
#Example : OPTIONAL_CONFIG_TOOLS = {"netca"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: s_responseFileName
#Type: String
s_responseFileName=<Value Unspecified>

#Parameter: s_netCAInstalledProtocols
#Type: String
s_netCAInstalledProtocols=<Value Unspecified>

#Parameter: s_netCAInstalledProducts
#Type: String
s_netCAInstalledProducts=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>

#Parameter: b_launchNETCA
#Type: Boolean
b_launchNETCA=<Value Unspecified>


[oracle.bc4j_9.0.2.692.1]
#Parameter: s_oracleJservPropertiesFile
#Type: String
#Description: Location of the JServ Properties file
s_oracleJservPropertiesFile=<Value Unspecified>

#Parameter: s_oc4jdeployini
#Type: String
#Description: Refer to deploy.ini under OH\j2ee\deploy.ini
s_oc4jdeployini=<Value Unspecified>

#Parameter: APACHE_HOME
#Type: String
#Description: Apache Home directory.
APACHE_HOME=<Value Unspecified>


[oracle.rdbms.ovm_9.2.0.1.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.soap.srv_2.0.0.0.0a]
#Parameter: b_serverInstalled
#Type: Boolean
#Description: set to true and passed to client when server is installed.
b_serverInstalled=<Value Unspecified>


[oracle.soap.cli_2.0.0.0.0a]
#Parameter: b_serverInstalled
#Type: Boolean
#Description: Bool set to true if soap server is installed.
b_serverInstalled=<Value Unspecified>

#Parameter: s_hostPort
#Type: String
#Description: Host and Port number used in url to soap server
s_hostPort=<Value Unspecified>


[oracle.jdk_1.4.2.0.0]
#Parameter: s_jdkVersion
#Type: String
s_jdkVersion=<Value Unspecified>

#Parameter: isNT
#Type: Boolean
isNT=<Value Unspecified>

#Parameter: JRE_LIBHOME
#Type: String
JRE_LIBHOME=<Value Unspecified>

#Parameter: JRE_LIB
#Type: String
JRE_LIB=<Value Unspecified>

#Parameter: JRE_BIN
#Type: String
JRE_BIN=<Value Unspecified>

#Parameter: JDK_HOME
#Type: String
JDK_HOME=<Value Unspecified>


[oracle.java.j2ee.core_9.2.0.1.0]
#Parameter: JDK_HOME
#Type: String
#Description: This is the top level directory where the JDK lives.
JDK_HOME=<Value Unspecified>


[oracle.rdbms.common_schema_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.rsf_9.2.0.1.0]
#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.options.ops.opsca_9.2.0.1.0]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    clustca,   : Oracle Cluster Configuration Assistant
#Example : OPTIONAL_CONFIG_TOOLS = {"clustca"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>

#Parameter: s_cfgtyperet
#Type: String
s_cfgtyperet=<Value Unspecified>


[oracle.rsf.nlsrtl_rsf_9.2.0.4.0]
#Parameter: s_serverInstallType
#Type: String
s_serverInstallType=<Value Unspecified>


[oracle.options.ops.pfs_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.oid.tools_9.2.0.1.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rsf.ssl_rsf_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.rsf.rdbms_rsf_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.rsf.xdk_rsf_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.install.instcommon_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.doc.unixdoc_9.2.0.1.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.rsf.hybrid_9.2.0.1.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.apache.jserv_1.1.0.0.0g]
#Parameter: s_soapPort
#Type: String
#Description: The port that soap/JServ listens to
s_soapPort=<Value Unspecified>

#Parameter: s_jservPort
#Type: String
#Description: The port Apache JServ listens to
s_jservPort=<Value Unspecified>

#Parameter: s_LANGUAGE_TERRITORY
#Type: String
#Description: Substring of n_NLSLANG
s_LANGUAGE_TERRITORY=<Value Required>

#Parameter: b_autoPortDetect
#Type: Boolean
#Description: Set to true by default, set to false for silent install
b_autoPortDetect=<Value Unspecified>

#Parameter: s_topDir
#Type: String
#Description: APACHE_TOP directory for Apache Web Server
s_topDir=<Value Unspecified>

#Parameter: s_jvm
#Type: String
#Description: Path to the Java Virtual Machine
s_jvm=<Value Unspecified>

#Parameter: APACHE_HOME
#Type: String
#Description: location of apache home
APACHE_HOME=<Value Unspecified>

#Parameter: s_oracleApacheConfigFile
#Type: String
#Description: location of the oracle_apache.conf file
s_oracleApacheConfigFile=<Value Unspecified>

#Parameter: s_oracleJservPropertiesFile
#Type: String
#Description: Location of the jserv.properties file
s_oracleJservPropertiesFile=<Value Unspecified>


[oracle.apache.jsdk_2.0.0.0.0d]
#Parameter: s_topDir
#Type: String
#Description: APACHE_TOP directory for Apache Web Server
s_topDir=<Value Unspecified>


[oracle.rsf.net_rsf_9.2.0.4.0]
#Parameter: s_bundleName
#Type: String
s_bundleName=<Value Unspecified>


[oracle.ocs4j_2.1.0.0.0a]
#Parameter: s_cachePort
#Type: String
#Description: Port to run local cache service on by default
s_cachePort=<Value Unspecified>


[oracle.rdbms.aqapi_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.java.sqlj.sqljruntime_9.2.0.4.0]
#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


[oracle.apache.apache_1.3.22.0.0a]
#Parameter: OPTIONAL_CONFIG_TOOLS
#Type: StringList
#Description: List of Optional Config tools that needs to be launched.
#The following choices are available. The value should contain only one of these choices.
#The choices are of the form Internal Name : External name. Please use the internal name while specifying the value.
#    configtool3,   : Starting HTTP Server
#    configtool8,   : Starting Oracle HTTP service
#Example : OPTIONAL_CONFIG_TOOLS = {"configtool3"}
OPTIONAL_CONFIG_TOOLS=<Value Unspecified>

#Parameter: sl_OHs
#Type: StringList
#Description: Holds oracle homes on machine
sl_OHs=<Value Unspecified>

#Parameter: s_apacheServerAppendText
#Type: String
#Description: This variable holds a concatenation of port configurations for apache server
s_apacheServerAppendText=<Value Required>

#Parameter: s_apachePortSSL
#Type: String
#Description: Port number that apache uses for SSL port when starting in SSL mode.  Default 443
s_apachePortSSL=<Value Unspecified>

#Parameter: s_apachePortNonSSL
#Type: String
#Description: Port number that apache uses when starting in non-ssl mode
s_apachePortNonSSL=<Value Unspecified>

#Parameter: s_apachePort
#Type: String
#Description: Port number that apache uses when starting in ssl mode
s_apachePort=<Value Unspecified>

#Parameter: s_NLSLANG
#Type: String
#Description: String containing NLSLANG info
s_NLSLANG=<Value Required>

#Parameter: b_autoStartApache
#Type: Boolean
#Description: pass in true to have apache autostart when not using top level component
b_autoStartApache=<Value Unspecified>

#Parameter: b_autoPortDetect
#Type: Boolean
#Description: True by default, this variable should be set to false for silent installs.
b_autoPortDetect=<Value Unspecified>

#Parameter: s_topDir
#Type: String
#Description: top level directory for Apache Web Server
s_topDir=<Value Unspecified>

#Parameter: ServerRoot
#Type: String
#Description: root directory of apache server
ServerRoot=<Value Unspecified>

#Parameter: APACHE_HOME
#Type: String
#Description: Apache location off of ORACLE_HOME
APACHE_HOME=<Value Unspecified>


[oracle.swd.jre_1.4.2.0.0]
#Parameter: PROD_HOME
#Type: String
#Description: Complete path where the product needs to be installed.
#Example : PROD_HOME = "C:\ProductName"
PROD_HOME=<Value Unspecified>

#Parameter: s_OPSSelectedNodes
#Type: String
s_OPSSelectedNodes=<Value Unspecified>


" > $SCRIPT_DIR/enterprise.rsp

# xhost +
xhost +

echo "$ORACLE_SW_STG/Disk1/runInstaller -waitforcompletion -responseFile $SCRIPT_DIR/enterprise.rsp -silent" > ${SCRIPT_DIR}/inst_ora_sw2
# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw2
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw2

# log checker of oracle installer
until [ "$OUTPUT" = "Result code for launching of configuration tool is 0" ]; do
  OUTPUT=`grep 'Result code for launching of configuration tool is 0' $ORACLE_BASE/oraInventory/logs/installActions*.log`
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
#rm -f ${SCRIPT_DIR}/inst_ora_sw
#rm -f ${SCRIPT_DIR}/inst_ora_sw2
#rm -f ${SCRIPT_DIR}/enterprise.rsp
#rm -rf $ORACLE_SW_STG
