lines_in_file () {
cat $1 | wc -l
}

selinux_disabled () {
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
}

yum_repo () {
if [ "$1" = "CentOS-4" ]; then
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
elif [ "$1" = "CentOS-5" ]; then
  echo "# CentOS-Base.repo
#
# This file uses a new mirrorlist system developed by Lance Davis for CentOS.
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#
[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
#baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
baseurl=http://vault.centos.org/5.5/os/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
#released updates
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
#baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
baseurl=http://vault.centos.org/5.5/updates/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=addons
#baseurl=http://mirror.centos.org/centos/\$releasever/addons/\$basearch/
baseurl=http://vault.centos.org/5.5/addons/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
#baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
baseurl=http://vault.centos.org/5.5/extras/\$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/\$releasever/centosplus/\$basearch/
baseurl=http://vault.centos.org/5.5/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5" > /etc/yum.repos.d/CentOS-Base.repo
else
  echo version unknown
fi
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
    value=$( grep -ic "unable" /tmp/xtest )
    if [ "$value" -eq 1 ]; then
      #echo "exiting, check XMING or firewall or X0.hosts file"
      return 1
    else
      return 0
    fi
  fi
fi
}
