#
# Tested Redhat 6.2 (Zoot)
# Checklist
# [Oracle 8.1.7.4 patch] - /tmp/lnx32_8174_patchset.tar
# [xming] will be serving runInstaller as xwindow server, oracle server will be xwindow client
#  Install xming on your workstation
#  Make sure oracle server ip is added to x0.hosts under xming directory (e.g. C:\Program Files (x86)\Xming\X0.hosts)
#  Turn off Windows firewall on your workstation to let xming traffic pass through
#  Make sure xming is launched on your workstation
# 


#
# Database patchset installation, run as root user
#

O_USER=oracle
ORACLE_BASE=/opt/app/oracle
ORACLE_HOME=/opt/app/oracle/product/8.1.7
ORACLE_SW1=/tmp/lnx32_8174_patchset.tar
ORACLE_SW_STG=/tmp/8174
INST_ORACLE_SW_SHELL=/tmp/inst_ora_sw.sh
XMING_IP=192.168.1.16

# Making shell script for oracle installer
echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
tar xvf $ORACLE_SW1
export DISPLAY=$XMING_IP:0.0
$ORACLE_BASE/oui/install/runInstaller" > $INST_ORACLE_SW_SHELL

# Adding execute permission to all users
chmod a+x $INST_ORACLE_SW_SHELL

# unzip; set DISPLAY; runInstaller as oracle
su - $O_USER -c $INST_ORACLE_SW_SHELL
