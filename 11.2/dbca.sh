#!/usr/bin/bash

#
# Tested CentOS Linux release 7.6.1810 (Core)
# Database creation, run as oracle user
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname $ORACLE_SID -sid $ORACLE_SID -responseFile NO_VALUE -characterSet AL32UTF8 -memoryPercentage 10 -emConfiguration NONE -datafiledestination /ora/db001 -sysPassword SysPassword1 -systemPassword SysPassword1 -dbsnmpPassword SysPassword1 -sysmanPassword SysPassword1

# Change auto start flag from N to Y
sed -e "/$CDB/s/^/#/g" $ORATAB > ${SCRIPT_DIR}/tmporatab
grep "$CDB.*:N" $ORATAB | sed s'/..$/:Y/' >> ${SCRIPT_DIR}/tmporatab
cat ${SCRIPT_DIR}/tmporatab > $ORATAB
rm -f ${SCRIPT_DIR}/tmporatab
