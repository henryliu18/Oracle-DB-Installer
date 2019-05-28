lines_in_file () {
cat $1 | wc -l
}

gcc32 () {
mv /usr/bin/gcc /usr/bin/gcc34
mv /usr/bin/gcc32 /usr/bin/gcc
}

gcc34 () {
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc
}

cr_orsinst () {
echo "inventory_loc=$ORACLE_BASE/oraInventory
inst_group=oinstall" > /etc/oraInst.loc
}

cr_directories () {
mkdir -p $ORACLE_HOME
mkdir -p $ORACLE_DB/data001
mkdir -p $ORACLE_DB/dbfra001
mkdir -p $ORACLE_DB/redo001
mkdir -p $ORACLE_DB/redo002

chown -R $O_USER:oinstall $ORACLE_BASE $ORACLE_DB
chmod -R 775 $ORACLE_BASE $ORACLE_DB
}

iptables_off () {
/etc/init.d/iptables stop
chkconfig iptables off
}

ipchains_off () {
/etc/rc.d/init.d/ipchains stop
chkconfig ipchains off
}

firewall_off () {
systemctl stop firewalld
systemctl disable firewalld
}

xming_check () {
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
  #echo "exiting, check XMING or firewall or X0.hosts file"
  return 1
else
  value=$( grep -ic "refused" /tmp/xtest )
  if [ "$value" -eq 1 ]; then
    #echo "exiting, check XMING or firewall or X0.hosts file"
    return 1
  else
    return 0
  fi
fi
}
