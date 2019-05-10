# Revert gcc 3.4 from gcc 3.2
mv /usr/bin/gcc /usr/bin/gcc32
mv /usr/bin/gcc34 /usr/bin/gcc

# Cleanup
rm -rf /tmp/ora9i
rm -f /tmp/inst_ora_sw.sh
rm -f /tmp/amd64_db_9204_Disk*
