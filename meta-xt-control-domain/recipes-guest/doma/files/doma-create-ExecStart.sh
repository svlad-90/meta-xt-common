#!/bin/bash

echo "Sleeping 5 seconds" && sleep 5;

echo "Creating DomA" && LIBXL_DEBUG_DUMP_DTB=/home/root/guest.dtb /usr/sbin/xl -v create /etc/xen/doma.cfg && \
echo "Created DomA" && \
echo "Pausing DomA" && /usr/sbin/xl -v pause DomA && \
echo "Paused DomA" && \
DOMD_ID=$(xl list | awk '{ if ($1 == "DomD") print $2 }') && \
DOMA_ID=$(xl list | awk '{ if ($1 == "DomA") print $2 }') && \
echo "Parsed DOMD_ID is '${DOMD_ID}'" && \
echo "Parsed DOMA_ID is '${DOMA_ID}'" && \
echo "Writing QEMU command to xen-store" && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/value \
"echo \"QEMU starting.\"; \
export SDL_VIDEODRIVER=wayland; \
qemu-system-aarch64 \
-xen-domid ${DOMA_ID} \
-xen-attach \
-M xenpv \
-m $(grep "memory =" < /etc/xen/doma.cfg | sed -rne 's/^.*memory = ([0-9]+).*/\1/p') \
-smp $(grep "vcpus =" < /etc/xen/doma.cfg | sed -rne 's/^.*vcpus = ([0-9]+).*/\1/p') \
-d guest_errors \
-monitor telnet:127.0.0.1:1234,server,nowait \
-device virtio-net-pci,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=1,romfile=\"\",id=nic0,netdev=net0,mac=08:00:27:ff:cb:ce \
-netdev type=tap,id=net0,ifname=vif-emu,br=xenbr0,script=no,downscript=no \
-device virtio-blk-pci,scsi=off,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=2,drive=image \
-drive if=none,id=image,format=raw,file=/dev/mmcblk0p3 \
-device virtio-gpu-gl-pci,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=3 \
-display sdl,gl=on \
-vga std \
-global virtio-mmio.force-legacy=false \
-device virtio-keyboard-pci,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=4 \
-audiodev alsa,id=snd0,out.dev=default \
-device virtio-snd-pci,audiodev=snd0,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=5 \
-device vhost-vsock-pci,guest-cid=3,disable-legacy=on,iommu_platform=on,bus=pcie.0,addr=6 \
-full-screen & \
QEMU_PID=\$!; \
sleep 5 && brctl addif xenbr0 vif-emu && ifconfig vif-emu up && \
sleep 3 && \
echo \"QEMU started.\" && \
/usr/bin/xenstore-write drivers/domd-qemu-monitor/status ready && \
wait \${QEMU_PID};" \
echo "Writing QEMU command status to xen-store" && \
/usr/bin/xenstore-write /local/domain/${DOMD_ID}/drivers/dom0-qemu-command-monitor/status ready;
