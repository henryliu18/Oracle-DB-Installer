#!/bin/bash

#
# Tested CentOS 5.5
# Database software installation post jobs, run as root user
#

ORACLE_BASE=/opt/app/oracle
ORACLE_HOME=/opt/app/oracle/product/10.2.0/db_1

# execute last 2 scripts as root
$ORACLE_BASE/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh<<EOF
/usr/local/bin
EOF

# Cleanup
rm -f /tmp/inst_ora_sw.sh
rm -f /tmp/10201_database_linux_x86_64*
rm -rf /tmp/ora10g
