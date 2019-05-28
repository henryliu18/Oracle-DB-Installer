lines_in_file () {
cat $1 | wc -l
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
