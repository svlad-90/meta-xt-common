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
    file://domu-create-ExecStartPost.sh \
    file://domu-create-ExecStop.sh \
    file://domu-restart-monitor.service \
    file://domu-restart-monitor-ExecStart.sh \
"

FILES:${PN} = " \
    ${sysconfdir}/xen/domu.cfg \
    ${libdir}/xen/boot/domu.dtb \
    ${libdir}/xen/boot/linux-domu \
    ${systemd_unitdir}/system/domu-create.service \
    ${systemd_unitdir}/system/domu-unpause.service \
    ${libdir}/xen/bin/domu-create-ExecStartPost.sh \
    ${libdir}/xen/bin/domu-create-ExecStop.sh \
    ${systemd_unitdir}/system/domu-restart-monitor.service \
    ${libdir}/xen/bin/domu-restart-monitor-ExecStart.sh \
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
    install -m 0755 ${WORKDIR}/domu-create-ExecStartPost.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/domu-create-ExecStop.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/domu-restart-monitor-ExecStart.sh ${D}${libdir}/xen/bin/
}
