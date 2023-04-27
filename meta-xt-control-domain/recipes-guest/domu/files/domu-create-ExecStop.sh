#!/bin/bash

DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
/usr/sbin/xl destroy DomU && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status dead;

