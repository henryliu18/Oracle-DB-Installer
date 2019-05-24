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

# XMING checks
export DISPLAY=$XMING_IP:0.0
(xdpyinfo>/tmp/xtest 2>&1) &
my_pid=$!

i=0
while   ps | grep " $my_pid ">/dev/null     # might also need  | grep -v grep  here
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
# do patching here
# Replace gcc 3.4 with gcc 3.2 - root task
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc

echo "mkdir $SCRIPT_DIR/9208
cd $SCRIPT_DIR/9208
unzip /tmp/p4547809_92080_Linux-x86-64.zip
$SCRIPT_DIR/9208/Disk1/runInstaller -silent -responseFile NO_VALUE \
UNIX_GROUP_NAME=\"oinstall\"
FROM_LOCATION="$SCRIPT_DIR/9208/Disk1/stage/products.xml" \
ORACLE_HOME=\$ORACLE_HOME \
ORACLE_HOME_NAME=\"OraHome92\"
" > ${SCRIPT_DIR}/inst_ora_sw

# Adding execute permission to all users
chmod a+x ${SCRIPT_DIR}/inst_ora_sw
# unzip; runInstaller as oracle
su - $O_USER -c ${SCRIPT_DIR}/inst_ora_sw

# Revert gcc 3.4 from gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc
  fi
fi
