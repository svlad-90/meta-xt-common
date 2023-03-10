inherit base

# PARAMETERS

UBOOT_REPO_GIT_URL="github.com/svlad-90/android_u-boot_manifest"
UBOOT_REPO_GIT_URL_DOTTED="github.com.svlad-90.android_u-boot_manifest"
UBOOT_REPO_DOWNLOAD_PROTOCOL="https"
UBOOT_REPO_GIT_BRANCH="xenvm-trout-master"
UBOOT_REPO_MANIFEST="default.xml"

# IMPLEMENTATION

UBOOT_DOWNLOAD_REPO_DIR="${DL_DIR}/repo/${UBOOT_REPO_GIT_URL_DOTTED}/${UBOOT_REPO_MANIFEST}"
UBOOT_LOCAL_REPO_RELATIVE_PATH="repo/${UBOOT_REPO_GIT_URL_DOTTED}/${UBOOT_REPO_MANIFEST}"
UBOOT_LOCAL_REPO_DIR="${WORKDIR}/${UBOOT_LOCAL_REPO_RELATIVE_PATH}"
UBOOT_BUILD_DIR="${B}/${UBOOT_REPO_GIT_URL_DOTTED}/${UBOOT_REPO_MANIFEST}/${U_BOOT_BUILD_TARGET}"

SRC_URI="\
    repo://${UBOOT_REPO_GIT_URL};protocol=${UBOOT_REPO_DOWNLOAD_PROTOCOL};branch=${UBOOT_REPO_GIT_BRANCH};manifest=${UBOOT_REPO_MANIFEST}  \
"

LICENSE="GPLv2+"
LIC_FILES_CHKSUM="file://${WORKDIR}/${UBOOT_LOCAL_REPO_RELATIVE_PATH}/repo/u-boot/Licenses/README;md5=2ca5f2c35c8cc335f0a19756634782f1"

FILES:${PN} = " \
    ${libdir}/xen/boot/u-boot-doma \
"

U_BOOT_BUILD_TARGET="xen-guest-android-virtio_aarch64"

do_unpack() {
    if ! [ -d ${UBOOT_LOCAL_REPO_DIR} ]; then
        mkdir -p ${UBOOT_LOCAL_REPO_DIR};
        cp -r ${UBOOT_DOWNLOAD_REPO_DIR}/* ${UBOOT_LOCAL_REPO_DIR}/;
    fi
}

python do_clean:prepend() {
    import subprocess

    UBOOT_LOCAL_REPO_DIR = d.getVar('UBOOT_LOCAL_REPO_DIR')

    bash_command = f"if [ -d {UBOOT_LOCAL_REPO_DIR} ]; then " \
    f"cd {UBOOT_LOCAL_REPO_DIR}/repo; " \
    "tools/bazel clean --expunge; " \
    "tools/bazel shutdown; " \
    "fi;"
    subprocess.run(bash_command, shell=True, check=True)
}

do_compile() {
    cd ${UBOOT_LOCAL_REPO_DIR}/repo;
    export CC=""
    export CXX=""
    export LD=""
    export LDFLAGS=""
    export CFLAGS=""
    export CXXFLAGS=""
    # Use it instead if you want to get more debug build artifacts.
    # tools/bazel run //u-boot:${U_BOOT_BUILD_TARGET}_dist --verbose_failures --sandbox_debug -- --dist_dir=${UBOOT_BUILD_DIR};
    tools/bazel run //u-boot:${U_BOOT_BUILD_TARGET}_dist -- --dist_dir=${UBOOT_BUILD_DIR};
    tools/bazel shutdown;
}

do_install() {
    install -d ${D}/${libdir}/xen/boot/
    install -m 0644 ${UBOOT_BUILD_DIR}/u-boot.bin \
        ${D}/${libdir}/xen/boot/u-boot-doma
}

do_deploy() {
    # Don't deploy anything
    return 0
}

