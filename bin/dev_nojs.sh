#!/usr/bin/env bash

if [ -f /app/tmp/pids/server.pid ] ; then
	if [ "$KILLPID" == "yes" ] ; then
		rm /app/tmp/pids/server.pid 
	fi
fi

echo "Starting rails server on PORT: '$PORT', ADDR: '$ADDR'"
./bin/rails server -p ${PORT:-3000} -b ${ADDR:-127.0.0.1}
