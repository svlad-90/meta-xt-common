#!/bin/bash

DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
( /usr/sbin/xl destroy DomU || true ) && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status dead;

# Let's wait for hanging domains to shutdown
HANGING_DOMAIN_ID_MEMORIZED="";

while true; do
    HANGING_DOMAIN_ID=$(xl list | awk '{ if ($1 == "(null)") print $2 }');

    if [ "$HANGING_DOMAIN_ID" = "" ]; then
        if [ -n "$HANGING_DOMAIN_ID_MEMORIZED" ]; then
             echo "Shutdown of the hanging domain with id '${HANGING_DOMAIN_ID_MEMORIZED}' has finished.";
        fi
        exit 0;
    else
        HANGING_DOMAIN_ID_MEMORIZED=${HANGING_DOMAIN_ID};
        echo "Waiting for the hanging domain with id '${HANGING_DOMAIN_ID_MEMORIZED}' to shutdown";
        sleep 1;
    fi
done
