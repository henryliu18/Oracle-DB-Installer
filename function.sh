lines_in_file () {
cat $1 | wc -l
}

kernel_params () {
if [ "$1" = "8.1.7" ]; then
  echo nothing here
elif [ "$1" = "9.2" ]; then
  echo "kernel.sem = 250 32000 100 128
kernel.shmmax = 2147483648
kernel.shmmni = 128
kernel.shmall = 2097152
kernel.msgmnb = 65536
kernel.msgmni = 2878
fs.file-max = 65536
net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf
#Run the following command to change the current kernel parameters.
sysctl -p
elif [ "$1" = "10.2" ]; then
  echo "kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 101365
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 1048576
net.core.rmem_max = 1048576
net.core.wmem_default = 262144
net.core.wmem_max = 262144" >> /etc/sysctl.conf
sysctl -p
elif [ "$1" = "11.2" ]; then
  echo "fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
# semaphores: semmsl, semmns, semopm, semmni
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048586" >> /etc/sysctl.conf
#Run the following command to change the current kernel parameters.
/sbin/sysctl -p
elif [ "$1" = "12c" ]; then
  echo "fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
#Run the following command to change the current kernel parameters.
/sbin/sysctl -p
elif [ "$1" = "18c" ]; then
  echo "fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
#Run the following command to change the current kernel parameters.
/sbin/sysctl -p
else
  echo version unknown
fi
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
