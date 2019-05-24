#!/bin/bash

#
# Database patchset installation, run as root user
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

if [ ! -f $SCRIPT_DIR/p4547809_92080_Linux-x86-64.zip ]; then
  echo "patch file not found here -> $SCRIPT_DIR/p4547809_92080_Linux-x86-64.zip"
  exit
else
# do patching here
# Replace gcc 3.4 with gcc 3.2 - root task
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc

echo "RESPONSEFILE_VERSION=2.2.1.0.0
UNIX_GROUP_NAME=\"oinstall\"
FROM_LOCATION=\"$SCRIPT_DIR/9208/Disk1/stage/products.xml\"
ORACLE_HOME=\"$ORACLE_HOME\"
ORACLE_HOME_NAME="OraHome92"
TOPLEVEL_COMPONENT={\"oracle.server\",\"9.2.0.8.0\"}
DEINSTALL_LIST={\"oracle.server\",\"9.2.0.8.0\"}
SHOW_SPLASH_SCREEN=true
SHOW_WELCOME_PAGE=false
SHOW_COMPONENT_LOCATIONS_PAGE=false
SHOW_CUSTOM_TREE_PAGE=false
SHOW_SUMMARY_PAGE=true
SHOW_INSTALL_PROGRESS_PAGE=true
SHOW_REQUIRED_CONFIG_TOOL_PAGE=true
SHOW_CONFIG_TOOL_PAGE=true
SHOW_XML_PREREQ_PAGE=true
SHOW_RELEASE_NOTES=true
SHOW_END_OF_INSTALL_MSGS=true
SHOW_ROOTSH_CONFIRMATION=true
SHOW_END_SESSION_PAGE=true
SHOW_EXIT_CONFIRMATION=true
NEXT_SESSION=true
NEXT_SESSION_ON_FAIL=true
SHOW_DEINSTALL_CONFIRMATION=true
SHOW_DEINSTALL_PROGRESS=true
ACCEPT_LICENSE_AGREEMENT=true" > $SCRIPT_DIR/patchset-9208.rsp

echo "mkdir $SCRIPT_DIR/9208
cd $SCRIPT_DIR/9208
unzip $SCRIPT_DIR/p4547809_92080_Linux-x86-64.zip
$SCRIPT_DIR/9208/Disk1/runInstaller -silent -responseFile $SCRIPT_DIR/patchset-9208.rsp
" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

## root.sh as root
#$ORACLE_HOME/root.sh<<EOF
#/usr/local/bin
#EOF

# Revert gcc 3.4 from gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc

fi
