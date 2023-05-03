#!/bin/bash

# Fetch DomA Xen domain identifier
DOMA_ID="";

while [ "$DOMA_ID" == "" ]; do
    DOMA_ID=$(xl list | awk '{ if ($1 == "DomA") print $2 }');

    if [ "$DOMA_ID" = "" ]; then
        sleep 1
    else
        echo "Parsed DOMA_ID is '${DOMA_ID}'";
    fi
done

XS_PATH="/local/domain/$DOMA_ID"

# Fetch first availability of the parameter
until xenstore-read $XS_PATH; do
    sleep 1
done

echo "Domain 'DomA' has become available.";

while true; do
	# Wait for the change in the parameters tree
    xenstore-watch -n2 $XS_PATH > /dev/null;

    if ! xenstore-read $XS_PATH; then
        echo "Domain 'DomA' with id '${DOMA_ID}' has become unavailable. \
Failing to notify dependent services. Will be restarted soon ...";
        exit 1;
    fi
done
