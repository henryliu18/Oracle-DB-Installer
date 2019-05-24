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

echo "netca /silent /responsefile \$ORACLE_HOME/network/install/netca_typ.rsp" > ${SCRIPT_DIR}/run_netca
chmod a+x ${SCRIPT_DIR}/run_netca
su - $O_USER -c ${SCRIPT_DIR}/run_netca
rm -f ${SCRIPT_DIR}/run_netca
