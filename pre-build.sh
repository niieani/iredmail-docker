#!/bin/bash

## This script prepares iRedMail source for dockerization ##

# apt-get install bzip2
wget "https://bitbucket.org/zhb/iredmail/downloads/iRedMail-0.9.4.tar.bz2"
tar xjf iRedMail-*.tar.bz2

prefix=(./iRedMail*)
# echo "$prefix"

[[ ! -d "$prefix" ]] && echo 'Failed to download/unpack the source' && exit 1

replace() {
  LC_ALL=C sed -i "s/$(echo "$1" | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo "$2" | sed -e 's/[\/&]/\\&/g')/g" "$3"
}

prepend() {
  replace "$1" "${2}${1}" "$3"
}

iredmailPackagesScript="${prefix}/functions/packages.sh"
cleanupScript="${prefix}/functions/cleanup.sh"
installScript="${prefix}/iRedMail.sh"
globalConf="${prefix}/conf/global"
webserverScript="${prefix}/functions/web_server.sh"
optionalScript="${prefix}/functions/optional_components.sh"

usePre='if [[ "${DOCKER_BUILD_'
usePost=':-FALSE}" == TRUE ]]; then '
useEnd='fi; '

ifUse() {
  local app="$1"
  echo "${usePre}${app}${usePost}"
}

endIfUse() {
  local app="$1"
  echo "${useEnd}${usePre}${app}${usePost}"
}

replace '# Enable syslog or rsyslog.' "$(ifUse SYSLOG)" "$iredmailPackagesScript"
replace '# Postfix.' "$(endIfUse POSTFIX)" "$iredmailPackagesScript"
replace '# Backend: OpenLDAP, MySQL, PGSQL and extra packages.' "$(endIfUse BACKEND)" "$iredmailPackagesScript"
replace '# PHP' "$(endIfUse PHP)" "$iredmailPackagesScript"
replace '# Apache. Always install Apache.' "$(endIfUse APACHE)" "$iredmailPackagesScript"
replace '# Nginx' "$(endIfUse NGINX)" "$iredmailPackagesScript"
replace '# Dovecot.' "$(endIfUse DOVECOT)" "$iredmailPackagesScript"
replace '# Amavisd-new & ClamAV & Altermime.' "$(endIfUse AMAVISD)" "$iredmailPackagesScript"
replace '# Roundcube' "$(endIfUse ROUNDCUBE)" "$iredmailPackagesScript"
replace '# SOGo' "$(endIfUse SOGO)" "$iredmailPackagesScript"
replace '# iRedAPD.' "$(endIfUse IREDAPD)" "$iredmailPackagesScript"
replace '# iRedAdmin.' "$(endIfUse IREDADMIN)" "$iredmailPackagesScript"
replace '# Awstats.' "$(endIfUse AWSTATS)" "$iredmailPackagesScript"
replace '# Fail2ban' "$(endIfUse FAIL2BAN)" "$iredmailPackagesScript"
replace '# Misc packages & services.' "$(endIfUse MISC)" "$iredmailPackagesScript"
# useEnd
replace '# Disable Ubuntu firewall rules, we have iptables init script and rule file.' "$useEnd" "$iredmailPackagesScript"

# remove mysql-server and postfix-ldap (it's in the postfix installation)
replace 'postfix-ldap slapd ldap-utils libnet-ldap-perl mysql-server mysql-client libdbd-mysql-perl' 'slapd ldap-utils libnet-ldap-perl mariadb-client libdbd-mysql-perl' "$iredmailPackagesScript"
# add postfix-ldap
replace '${ALL_PKGS} postfix postfix-pcre' '${ALL_PKGS} postfix postfix-pcre postfix-ldap' "$iredmailPackagesScript"
replace '${ENABLED_SERVICES} ${OPENLDAP_RC_SCRIPT_NAME} ${MYSQL_RC_SCRIPT_NAME}' '${ENABLED_SERVICES} ${OPENLDAP_RC_SCRIPT_NAME}' "$iredmailPackagesScript"

prepend 'check_status_before_run cleanup_replace_firewall_rules' ': # ' "$cleanupScript"
prepend 'check_status_before_run cleanup_replace_mysql_config' '# ' "$cleanupScript"
prepend 'check_status_before_run cleanup_update_clamav_signatures' '[[ ${DOCKER_BUILD_AMAVISD:-FALSE} == TRUE ]] && ' "$cleanupScript"

replace 'check_env' '. ${IREDMAIL_CONFIG_FILE}' "$installScript"

prepend 'export HOSTNAME="$(hostname -f)"' '# ' "$globalConf"

prepend 'check_status_before_run generate_ssl_keys' '[[ ${DOCKER_BUILD_SSL:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run web_server_config' '[[ ${DOCKER_BUILD_NGINX:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run php_config' '[[ ${DOCKER_BUILD_PHP:-FALSE} == TRUE ]] && ' "$webserverScript"
prepend 'check_status_before_run backend_install' '[[ ${DOCKER_BUILD_BACKEND:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run postfix_config' '[[ ${DOCKER_BUILD_POSTFIX:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run enable_dovecot' '[[ ${DOCKER_BUILD_DOVECOT:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run clamav_config' '[[ ${DOCKER_BUILD_AMAVISD:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run amavisd_config' '[[ ${DOCKER_BUILD_AMAVISD:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run sa_config' '[[ ${DOCKER_BUILD_AMAVISD:-FALSE} == TRUE ]] && ' "$installScript"
prepend 'check_status_before_run iredapd_setup' '[[ ${DOCKER_BUILD_IREDAPD:-FALSE} == TRUE ]] && ' "$optionalScript"