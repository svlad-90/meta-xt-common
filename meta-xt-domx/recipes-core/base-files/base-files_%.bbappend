# Append domain name
# XT_DOM_NAME should be defined somewhere else. Like in local.conf
XT_DOM_NAME ??= "domx"
hostname .= "-${XT_DOM_NAME}"

do_install_append () {
        echo "shopt -s checkwinsize" >> ${D}${sysconfdir}/profile
        echo "eval \`resize\`> /dev/null" >> ${D}${sysconfdir}/profile
}
