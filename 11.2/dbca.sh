#!/usr/bin/bash

#
# Tested CentOS Linux release 7.6.1810 (Core)
# Database creation, run as oracle user
#

ORATAB=/etc/oratab
TMPORATAB=/tmp/oratab


dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname $ORACLE_SID -sid $ORACLE_SID -responseFile NO_VALUE -characterSet AL32UTF8 -memoryPercentage 10 -emConfiguration NONE -datafiledestination /ora/db001 -sysPassword SysPassword1 -systemPassword SysPassword1 -dbsnmpPassword SysPassword1 -sysmanPassword SysPassword1

# Change auto start flag from N to Y
sed -e "/$ORACLE_SID/s/^/#/g" $ORATAB > $TMPORATAB
grep "$ORACLE_SID.*:N" $ORATAB | sed s'/..$/:Y/' >> $TMPORATAB
cat $TMPORATAB $ORATAB
rm -f $TMPORATAB
