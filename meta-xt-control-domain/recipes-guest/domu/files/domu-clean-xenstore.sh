#!/bin/bash

DOMU_ID=$(xl list | awk '{ if ($1 == "DomU") print $2 }')

for i in `xenstore-ls /libxl/${DOMU_ID}/device/virtio | grep 'backend =' | awk '{print $3}'`
do
    i=${i%\"}
    i=${i#\"}
    xenstore-write $i/state "6"
    xenstore-write $i/online "0"
done
