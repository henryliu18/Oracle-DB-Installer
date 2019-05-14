#!/bin/bash

# Source env
if [ -f `dirname $0`/env ]; then
 . `dirname $0`/env
else
 echo "env file not found in `dirname $0`, run setup to create env file"
 echo "cd `dirname $0`;bash `dirname $0`/setup env"
 exit 1
fi

if [ "$O_VER" = "18c" ]; then
  bash `dirname $0`/18c/netca.sh
elif [ "$O_VER" = "12c" ]; then
  bash `dirname $0`/12c/netca.sh
elif [ "$O_VER" = "11.2" ]; then
  bash `dirname $0`/11.2/netca.sh
elif [ "$O_VER" = "10.2" ]; then
  bash `dirname $0`/10.2/netca.sh
elif [ "$O_VER" = "9.2" ]; then
  bash `dirname $0`/9.2/netca.sh
elif [ "$O_VER" = "8.1.7" ]; then
  bash `dirname $0`/8.1.7/netca.sh
fi
