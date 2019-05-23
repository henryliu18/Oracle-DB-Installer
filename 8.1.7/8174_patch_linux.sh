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

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

# Making shell script for oracle installer
echo "mkdir $ORACLE_SW_STG
cd $ORACLE_SW_STG
tar xvf $ORACLE_SW1
export DISPLAY=$XMING_IP:0.0
$ORACLE_BASE/oui/install/runInstaller" > $SCRIPT_DIR/inst_ora_sw

# Adding execute permission to all users
chmod a+x $SCRIPT_DIR/inst_ora_sw

# unzip; set DISPLAY; runInstaller as oracle
su - $O_USER -c $SCRIPT_DIR/inst_ora_sw

# cleanup
rm -f $SCRIPT_DIR/inst_ora_sw
