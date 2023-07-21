SUMMARY = "Set of files to run a generic guest domain"
DESCRIPTION = "A config file, kernel, dtb and scripts for a guest domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

EXTERNALSRC_SYMLINKS = ""

# We rely on the bash availability
RDEPENDS:${PN} = "bash"

SRC_URI = "\
    file://${XT_DOMU_CONFIG_NAME} \
    file://domu-vdevices.cfg \
    file://domu-create.service \
    file://domu-unpause.service \
    file://domu-create-ExecStart.sh \
    file://domu-create-ExecStopPost.sh \
    file://domu-restart-monitor.service \
    file://domu-restart-monitor-ExecStart.sh \
    file://domu-clean-xenstore.sh \
"

FILES:${PN} = " \
    ${sysconfdir}/xen/domu.cfg \
    ${libdir}/xen/boot/domu.dtb \
    ${libdir}/xen/boot/linux-domu \
    ${systemd_unitdir}/system/domu-create.service \
    ${systemd_unitdir}/system/domu-unpause.service \
    ${libdir}/xen/bin/domu-create-ExecStart.sh \
    ${libdir}/xen/bin/domu-create-ExecStopPost.sh \
    ${systemd_unitdir}/system/domu-restart-monitor.service \
    ${libdir}/xen/bin/domu-restart-monitor-ExecStart.sh \
    ${libdir}/xen/bin/domu-clean-xenstore.sh \
"

SYSTEMD_SERVICE:${PN} = "domu-create.service domu-unpause.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/${XT_DOMU_CONFIG_NAME} ${D}${sysconfdir}/xen/domu.cfg
    install -m 0644 ${S}/${XT_DOMU_DTB_NAME} ${D}${libdir}/xen/boot/domu.dtb
    install -m 0644 ${S}/Image ${D}${libdir}/xen/boot/linux-domu

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domu-create.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/domu-unpause.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/domu-restart-monitor.service ${D}${systemd_unitdir}/system/

    install -d ${D}${libdir}/xen/bin
    install -m 0755 ${WORKDIR}/domu-create-ExecStart.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/domu-create-ExecStopPost.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/domu-restart-monitor-ExecStart.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/domu-clean-xenstore.sh ${D}${libdir}/xen/bin/
}
