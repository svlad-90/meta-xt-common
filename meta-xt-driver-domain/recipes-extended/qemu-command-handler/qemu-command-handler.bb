SUMMARY = "Service for the block device up notification"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
    file://qemu-command-handler.service \
    file://qemu-command-handler-ExecStart.sh \
"
S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "qemu-command-handler.service"

RDEPENDS:${PN} = " \
    xen-tools-xenstore \
    bash \
"

RRECOMMENDS:${PN} += " \
    virtual/xenstored \
"

FILES:${PN} = " \
    ${systemd_system_unitdir}/qemu-command-handler.service \
    ${libdir}/xen/bin/qemu-command-handler-ExecStart.sh \
"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/qemu-command-handler.service ${D}${systemd_system_unitdir}

    install -d ${D}${libdir}/xen/bin
    install -m 0755 ${WORKDIR}/qemu-command-handler-ExecStart.sh ${D}${libdir}/xen/bin/
}
