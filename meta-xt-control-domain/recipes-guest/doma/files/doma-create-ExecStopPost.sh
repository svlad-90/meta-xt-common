#!/bin/bash

# Note!
#
# Below we are writing xen-storage status BEFORE executing destruction
# of the DomA Xen domain. That is done by intention in order to allow
# QEMU to be destroyed ASAP.
#
# At current moment, we are accessing '/dev/mmcblk0p3' device using
# both, 'PV block' and 'virtio' virtual devices. That is done,
# because AOSP uses MMC as a 'virtio' device shared by QEMU, while
# during the U-Boot phase a 'PV block' device shared by Xen is being
# used.
#
# Writing "dead" status to "drivers/dom0-qemu-command-monitor/status"
# of DomD will cause qemu-command-handler service in DomD to be
# stopped. That will unblock shutdown of the DomA guest domain.

DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status dead && \
echo "Destroying DomA" && ( /usr/sbin/xl -v destroy DomA || true ) && echo "Destroyed DomA"; \

# Let's wait for hanging domains to shutdown
HANGING_DOMAIN_ID_MEMORIZED="";

while true; do
    HANGING_DOMAIN_ID=$(xl list | awk '{ if ($1 == "(null)") print $2 }');

    if [ "$HANGING_DOMAIN_ID" = "" ]; then
        if [ -n "$HANGING_DOMAIN_ID_MEMORIZED" ]; then
             echo "Shutdown of the hanging domain with id '${HANGING_DOMAIN_ID_MEMORIZED}' has finished.";
        fi
        echo "DomA stopped!";
        exit 0;
    else
        HANGING_DOMAIN_ID_MEMORIZED=${HANGING_DOMAIN_ID};
        echo "Waiting for the hanging domain with id '${HANGING_DOMAIN_ID_MEMORIZED}' to shutdown";
        sleep 1;
    fi
done
