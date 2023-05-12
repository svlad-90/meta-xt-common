SUMMARY = "systemd service, which monitors availability of QEMU being running in DomD"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
RDEPENDS:${PN} = "backend-ready bash"

inherit systemd

SRC_URI = "\
    file://qemu-restart-monitor-ExecStart.sh \
    file://qemu-restart-monitor.service \
"

FILES:${PN} = " \
    ${libdir}/xen/bin/qemu-restart-monitor-ExecStart.sh \
    ${systemd_unitdir}/system/qemu-restart-monitor.service \
"

SYSTEMD_SERVICE:${PN} = "qemu-restart-monitor.service"

do_install() {
    install -d ${D}${libdir}/xen/bin
    install -m 0755 ${WORKDIR}/qemu-restart-monitor-ExecStart.sh ${D}${libdir}/xen/bin/qemu-restart-monitor-ExecStart.sh

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/qemu-restart-monitor.service ${D}${systemd_unitdir}/system/
}
