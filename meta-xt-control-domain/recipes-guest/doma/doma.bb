SUMMARY = "Set of files to run an Android-based guest "
DESCRIPTION = "A config file, dtb and scripts for a guest domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

EXTERNALSRC_SYMLINKS = ""

# We use custom U-BOOT to run the Android
# And also we rely on the bash availability
RDEPENDS:${PN} = "u-boot-android bash"

SRC_URI = "\
    file://doma-create.service \
    file://doma-unpause.service \
    file://doma-create-ExecStart.sh \
    file://doma-create-ExecStopPost.sh \
    file://doma-restart-monitor.service \
    file://doma-restart-monitor-ExecStart.sh \
"

python () {
    if d.getVar('XT_DOMA_CONFIG_NAME'):
        d.appendVar('SRC_URI', ' file://${XT_DOMA_CONFIG_NAME} ')
}

FILES:${PN} = " \
    ${sysconfdir}/xen/doma.cfg \
    ${libdir}/xen/boot/doma.dtb \
    ${systemd_unitdir}/system/doma-create.service \
    ${systemd_unitdir}/system/doma-unpause.service \
    ${libdir}/xen/bin/doma-create-ExecStart.sh \
    ${libdir}/xen/bin/doma-create-ExecStopPost.sh \
    ${systemd_unitdir}/system/doma-restart-monitor.service \
    ${libdir}/xen/bin/doma-restart-monitor-ExecStart.sh \
"

SYSTEMD_SERVICE:${PN} = "doma-create.service doma-unpause.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/${XT_DOMA_CONFIG_NAME} ${D}${sysconfdir}/xen/doma.cfg
    install -m 0644 ${S}/${XT_DOMA_DTB_NAME} ${D}${libdir}/xen/boot/doma.dtb

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/doma-create.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/doma-unpause.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/doma-restart-monitor.service ${D}${systemd_unitdir}/system/

    install -d ${D}${libdir}/xen/bin
    install -m 0755 ${WORKDIR}/doma-create-ExecStart.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/doma-create-ExecStopPost.sh ${D}${libdir}/xen/bin/
    install -m 0755 ${WORKDIR}/doma-restart-monitor-ExecStart.sh ${D}${libdir}/xen/bin/
}
