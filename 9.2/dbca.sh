#!/bin/bash

#
# Tested CentOS 4
# Listener configuration, run as root user
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
echo "dbca -silent -createDatabase -templateName General_Purpose.dbc \
-gdbname \$ORACLE_SID -sid \$ORACLE_SID -responseFile NO_VALUE -characterSet AL32UTF8 \
-memoryPercentage 10 -emConfiguration NONE -datafiledestination $ORACLE_DB \
-sysPassword $SYS_PASS -systemPassword $SYSTEM_PASS \
-dbsnmpPassword $SYSTEM_PASS -sysmanPassword $SYSTEM_PASS" > ${SCRIPT_DIR}/run_dbca
chmod a+x ${SCRIPT_DIR}/run_dbca
su - $O_USER -c ${SCRIPT_DIR}/run_dbca
rm -f ${SCRIPT_DIR}/run_dbca

# Change auto start flag from N to Y
  fi
fi
