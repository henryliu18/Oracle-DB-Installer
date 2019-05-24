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


# do patching here
# Replace gcc 3.4 with gcc 3.2 - root task
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc

echo "mkdir $SCRIPT_DIR/9208
cd $SCRIPT_DIR/9208
unzip /tmp/p4547809_92080_Linux-x86-64.zip
$SCRIPT_DIR/9208/Disk1/runInstaller -silent \
UNIX_GROUP_NAME=\"oinstall\" \
FROM_LOCATION="$SCRIPT_DIR/9208/Disk1/stage/products.xml" \
ORACLE_HOME=$ORACLE_HOME \
ORACLE_HOME_NAME=\"OraHome92\" \
TOPLEVEL_COMPONENT={\"oracle.server\",\"9.2.0.8.0\"} \
NEXT_SESSION=true
" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# Revert gcc 3.4 from gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc
