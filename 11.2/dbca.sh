#!/usr/bin/bash

#
# Tested CentOS 7
# Database creation, run as root user
#

# Source env
if [ -f ./env ]; then
 . ./env
else
 echo "env file not found, run setup to create env file"
 exit 1
fi

echo "dbca -silent -createDatabase -templateName General_Purpose.dbc \
-gdbname \$ORACLE_SID -sid \$ORACLE_SID -responseFile NO_VALUE -characterSet AL32UTF8 \
-memoryPercentage 10 -emConfiguration NONE -datafiledestination $ORACLE_DB \
-sysPassword $SYS_PASS -systemPassword $SYSTEM_PASS \
-dbsnmpPassword $SYSTEM_PASS -sysmanPassword $SYSTEM_PASS" > ${SCRIPT_DIR}/run_dbca
chmod a+x ${SCRIPT_DIR}/run_dbca
su - $O_USER -c ${SCRIPT_DIR}/run_dbca
rm -f ${SCRIPT_DIR}/run_dbca

# Change auto start flag from N to Y
sed -e "/$CDB/s/^/#/g" $ORATAB > ${SCRIPT_DIR}/tmporatab
grep "$CDB.*:N" $ORATAB | sed s'/..$/:Y/' >> ${SCRIPT_DIR}/tmporatab
cat ${SCRIPT_DIR}/tmporatab > $ORATAB
rm -f ${SCRIPT_DIR}/tmporatab
