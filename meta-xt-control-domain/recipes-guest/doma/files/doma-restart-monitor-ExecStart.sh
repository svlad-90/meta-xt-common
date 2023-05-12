#!/bin/bash

echo "DomA restart monitor started!";

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
        # We should notify here, that QEMU command is dead to unblock shutdown of the DomA.
        # DomA can be shutdown only after QEMU was shutdown.
        # Otherwise create-doma.service will stuck in 'deactivating' state due to the
        # mangling sub-process, which is created by the "xl create /etc/xen/doma.cfg",
        # which is started in the 'doma-create-ExecStart.sh' script
        #
        # The systemd output in the bad case looks like this:
        #
        # * doma-create.service - Android VM creator service
        # Loaded: loaded (8;;file://generic-armv8-xt-dom0/lib/systemd/system/doma-create.service/lib/systemd/system/doma-create.service8;;; enabled; vendor preset: enabled)
        # Drop-In: /etc/systemd/system/doma-create.service.d
        #     `-8;;file://generic-armv8-xt-dom0/etc/systemd/system/doma-create.service.d/doma-set-root.confdoma-set-root.conf8;;
        # Active: deactivating (stop-sigterm) since Thu 2022-04-28 18:04:13 UTC; 50min ago
        # Process: 431 ExecStartPre=/usr/lib/xen/bin/doma-set-root (code=exited, status=0/SUCCESS)
        # Process: 440 ExecStart=/usr/lib/xen/bin/doma-create-ExecStart.sh (code=exited, status=0/SUCCESS)
        # Main PID: 440 (code=exited, status=0/SUCCESS)
        # Tasks: 1 (limit: 223)
        # Memory: 864.0K
        # CGroup: /system.slice/doma-create.service
        #     `- 536 /usr/sbin/xl -v create /etc/xen/doma.cfg <<< this process stuck the flow in corner cases.
        echo "Workaround notification of the QEMU command unavailability." && \
        DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
        /usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status dead;
        echo "Domain 'DomA' with id '${DOMA_ID}' has become unavailable. \
Failing to notify dependent services. Will be restarted soon ...";
        exit 1;
    fi
done
