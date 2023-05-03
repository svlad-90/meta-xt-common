#!/bin/bash

DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
DOMU_ID=$(xl list | awk '{ if ($1 == "DomU") print $2 }') && \
echo "Parsed DOMD_ID is '${DOMD_ID}'" && \
echo "Writing QEMU command to xen-store" && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/value \
"export SDL_VIDEODRIVER=wayland; \
qemu-system-aarch64 \
-xen-domid ${DOMU_ID} \
-xen-attach \
-M xenpv \
-m $(grep "memory =" < /etc/xen/domu.cfg | sed -rne 's/^.*memory = ([0-9]+).*/\1/p') \
-smp $(grep "vcpus =" < /etc/xen/domu.cfg | sed -rne 's/^.*vcpus = ([0-9]+).*/\1/p') \
-d guest_errors \
-monitor /dev/null \
-device virtio-net-pci,disable-legacy=on,iommu_platform=on,romfile="",id=nic0,netdev=net0,mac=08:00:27:ff:cb:cf \
-netdev type=tap,id=net0,ifname=vif-emu,br=xenbr0,script=no,downscript=no \
-device virtio-blk-pci,scsi=off,disable-legacy=on,iommu_platform=on,drive=image \
-drive if=none,id=image,format=raw,file=/dev/mmcblk0p3 \
-device virtio-gpu-gl-pci,disable-legacy=on,iommu_platform=on \
-display sdl,gl=on \
-vga std \
-global virtio-mmio.force-legacy=false \
-device virtio-keyboard-pci,disable-legacy=on,iommu_platform=on \
-audiodev alsa,id=snd0,out.dev=default \
-device virtio-snd-pci,audiodev=snd0,disable-legacy=on,iommu_platform=on \
-full-screen & \
QEMU_PID=\$!; \
sleep 5 && brctl addif xenbr0 vif-emu && ifconfig vif-emu up && \
wait \${QEMU_PID}" && \
echo "Writing QEMU command status to xen-store" && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status ready;
