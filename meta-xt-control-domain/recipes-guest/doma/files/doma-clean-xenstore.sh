#!/bin/bash

DOMA_ID=$(xl list | awk '{ if ($1 == "DomA") print $2 }')

for i in `xenstore-ls /libxl/${DOMA_ID}/device/virtio | grep 'backend =' | awk '{print $3}'`
do
    i=${i%\"}
    i=${i#\"}
    xenstore-write $i/state "6"
done
