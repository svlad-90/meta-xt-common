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
/usr/sbin/xl destroy DomA; \

