#!/bin/bash

echo "QEMU restart monitor started!";

# Fetch DomD Xen domain identifier
DOMD_ID="";

while [ "$DOMD_ID" == "" ]; do
    DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }');

    if [ "$DOMD_ID" = "" ]; then
        sleep 1
    else
        echo "Parsed DOMD_ID is '${DOMD_ID}'";
    fi
done

XS_PATH="/local/domain/$DOMD_ID/drivers/domd-qemu-monitor/status"

CURRENT_STATUS="unknown"

while true; do
    if [ x$CURRENT_STATUS = x"unknown" ]; then
        xenstore-watch -n1 $XS_PATH > /dev/null
    else
        xenstore-watch -n2 $XS_PATH > /dev/null
    fi

    STATUS=`xenstore-read $XS_PATH`

    echo "QEMU status is '$STATUS'."
    if [ x$STATUS != x$CURRENT_STATUS ]; then
        if [ x$STATUS = x"dead" -a x$CURRENT_STATUS != x"unknown" ]; then
            echo "Failing to notify QEMU unavailability. Will be restarted soon ..."
            exit 1;
        fi
    fi

    CURRENT_STATUS=$STATUS
done


