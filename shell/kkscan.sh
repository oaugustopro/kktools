#!/bin/bash
# TODO
# o default tem as libs, o user, etc...
# verificar dependencias no inicio, mas mudar o script para só verificar o binário, se der erro ai ele pergunta se quer instalar e entao
  # Criar uma funcao checkExec, q verifica se algum binário da lista é válido, retorna esse binário, se for um script retorna o caminho completo.
# Usar AnimationLine para cada etapa...
# Usar o printMessage -n para notificacoes, -w alerta -g ok, -f fatal no lugar do centerprint
# Usar o spacedPrint para dar os OK ALERTA ERRO ou em ingles
# Colocar mais itens em help_options, ao inves de help_examples
# Adicionar help examples com exemplo de como usar
# Adicionar help_dependencies com os apps q são necessários
# usar progressbar com valores para nmap, mas nao ta dando
# Fazer funcao para paresear as opcoes e ficar mais bonito la no cas
# sed "s#\([^|]*\)\(|\)\(.*\)#\3#g;s#+##g"
# sed "s#\([^|]*\)\(|\)\(.*\)#\1#g;s#+##g"
# Fazer funcao para juntar os arguments e reunir tudo num local
# END TODO

## Import Libs
source default.conf || { echo "Error while loading source files"; exit 1; }
# Colocar no inicio do libkmrgobash algo para bypassar as dependencias, tiipo o lolcat
source libkmrgobash.sh || { echo "Error while loading source files"; exit 1; }
this=$(basename $0)

### Arguments
### Help variables
help_short_description="Enumerate computers and services"
help_version="0.2"
help_dependencies="lolcat figlet cowsay nmap nbtscan nmblookup smbclient smbmap nikto"
help_notes="Requer paciencia."

# ATENCAO
# Para adicionar opcoes, primeiro adicione aqui, depois adicione as linhas apropriadas no case, depois se na verificacao para execucao.
## OPTIONS
############################################################
############################################################
### MODIFIQUE OS ARGUMENTOS E PARAMETROS 
### SOMENTE 
### AQUI  ABAIXO
############################################################
############################################################
i=1 arg[$i]='-H|--help'; argument_name[$i]="help"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, mostra a ajuda."

i=2 arg[$i]="-M|--man"; argument_name[$i]="manual"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, mostra o MAN.\n"

i=3 arg[$i]="-V|--version"; argument_name[$i]="version"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, mostra a versão.\n"

i=4 arg[$i]="-n:|--network:"; argument_name[$i]="network address"; help_options[$i]="${arg[$i]//:/} networkaddr
\t${argument_name[$i]}, escaneia a rede inteira ou um range.\n"

i=5 arg[$i]="-h:|--host:"; argument_name[$i]="host address"; help_options[$i]="${arg[$i]//:/} host
\t${argument_name[$i]}, escaneira o host e todas as portas.\n"

i=6 arg[$i]="-p:|--port:"; argument_name[$i]="port numer or range"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, escaneia e busca vulnerabilidades em uma porta específica ou range de um host.\n"

i=7 arg[$i]="-A|--all"; argument_name[$i]="scan all"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, escaneia e busca na sequencia, o host, suas portas, banner grabbing e vulnerabilidades.\n"

i=8 arg[$i]="-f|--fast"; argument_name[$i]="fast"; help_options[$i]="${arg[$i]//:/} [host] [port]
\t${argument_name[$i]}, escaneia muito rapidamente, sem se preocupar com IPS, IDS ou firewall (opção default).\n"

i=9 arg[$i]="-s:|--services:"; argument_name[$i]="services"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]} [smb,ftp,ssh,wordpress,drupal,joomla,apache,nginx,mywebmin,myphpadmin,rpc,rdp,vnc,lxc,docker,dns,smtp,imap,pop,modbus,telnet,dhcp,nntp,ntp,netbios,ad,irc,http,https],  escaneia serviços.\n"

i=10 arg[$i]="--anon"; argument_name[$i]="anonymous"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, escaneia em modo anônimo.\n"

i=11 arg[$i]="-t:|--types:"; argument_name[$i]="types"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, seleciona o tipo de scan (-t vuln), se aplica ao tipo corrente, o tipo corrente pode ser: rede, host, portas ou serviço.\n"

i=12 arg[$i]="-u:|--url:"; argument_name[$i]="url"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, url para utilização em scans de serviço.\n"

i=13 arg[$i]="-w:|--wordlist:"; argument_name[$i]="wordlist"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, wordlist para bruteforce nos diretorios.\n"

i=14 arg[$i]="--unprivileged"; argument_name[$i]="unprivileged"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, para q o nmap nao rode usando pacotes icmp. Útil quando estiver em algum tipo de proxy.\n"

i=15 arg[$i]="-v|--verbose"; argument_name[$i]="verbose"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, para q o nmap nao rode usando pacotes icmp. Útil quando estiver em algum tipo de proxy.\n"

i=16 arg[$i]="-e:|--extra:"; argument_name[$i]="extra"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, extra arguments.\n"

i=17 arg[$i]="--proxy"; argument_name[$i]="proxy"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, roda via proxychains.\n"

## EXAMPLES
i=1; help_examples[$i]="$this -p 22 -h 192.168.1.2 --fast
\tescaneia o host, busca na porta 22 os serviços e vulnerabilidades, no modo rápido."
############################################################
############################################################
### MODIFIQUE OS ARGUMENTOS E PARAMETROS 
### SOMENTE
### AQUI ACIMA ACIMA ACIMA ACIMA ACIMA ACIMA ACIMA ACIMA
############################################################
############################################################
## SYNOPSIS
# Tem q ser igual ao q tem acima no array argument
help_synopsys_args="$(echo "${arg[@]}" | sed -E "s/|--[A-Za-z]+//g;s/[ \|-]//g;" | tr -s ':')"
help_synopsys_long="$(echo "${arg[@]}" | sed -E "s/-[A-Za-z:]+\|//g;s/[\|-]//g;s/[ ]/,/g" | tr -s ':')"
help_synopsis="$help_synopsys_args --${help_synopsys_long//,/ --}"

## COMMANDS
# scan methods
# o segundo nome é o nome da funcao, se estiver em cammel case, se nao, nao tem funcao relacionada
declare -A statusOptions
statusOptions['showversion']=false
statusOptions['scanfast']=false
statusOptions['anon']=false
statusOptions['proxy']=false
statusOptions['unprivileged']=false
statusOptions['printhelp']=false
statusOptions['printmanual']=false
statusOptions['scanall']=false

# Declaracao_variaveis
export prefix="krep"
# Fim_Declaracao_variaveis
# Declaracao_funcoes

parseArg(){
    case $2 in
        -l)
        echo "${1//:/}" | sed "s#\([^|]*\)\(|\)\(.*\)#\3#g;s#+##g"
        ;;
        *)
        echo "${1//:/}" | sed "s#\([^|]*\)\(|\)\(.*\)#\1#g;s#+##g"
        ;;
    esac
    
}

getIpTunTap () {
    ip -br a | grep -E 'tun|tap' | head -n 1 | awk '{print $3}' | cut -d / -f 1
}

generateDecoys() {
  local my_ip_adress=$(getIpTunTap)
  [ -z "$my_ip_adress" ] && my_ip_adress=$(ip -br a | grep -E 'wlan0' |  head -n 1 | awk '{print $3}' | cut -d / -f 1)
  [ -z "$my_ip_adress" ] && my_ip_adress=$(ip -br a | grep -E 'eth0' |  head -n 1 | awk '{print $3}' | cut -d / -f 1)
  local base_ip="$(echo $my_ip_adress | cut -d . -f 1-3)"  # Replace with the first three octets of your IP range
  local decoy_list=()
  # Generate list of unique random last octets
  octets=( $(shuf -i 20-190 -n 10 -o /dev/stdout | sort -nu) )

  # Generate 10 decoys, placing "ME" at the 6th position
  for i in $(seq 1 8); do
    if [ "$i" -eq 6 ]; then
      decoy_list+=("$my_ip_adress")  # Replace with your real IP
    else
      decoy_list+=("$base_ip.${octets[$i]}")
    fi
  done

  # Print decoys, comma-separated
  local IFS=,
  echo "${decoy_list[*]}"
  return 0
}

smbCheckPerm(){
    # Input params
    host="$1"
    user="$2"    
    pass="$3"

    # Colors
    RED='\033[1;31m'
    YELLOW='\033[1;33m'
    GRAY='\033[0;37m'
    RST='\033[0m'

    # Check host
    if [ -z "$host" ]
    then
        echo "Usage: $0 host [user] [pass]"
        echo "Default user and password is 'anon'"
        exit 1
    fi

    # Check user name and password
    if [ -z "$user" ] ; then user="anon" ; fi
    if [ -z "$pass" ] ; then pass="anon" ; fi

    # smbclient
    smbclient=$(which smbclient)

    # Checks read or write permission
    function checkReadWritePerm() {
        local share="$1"
        local tdir="$2"
        local tmpFile="$3"

        if $smbclient "//${host}/${share}/" -U "${user}%${pass}"  -c "cd ${tdir}; put ${tmpFile}; rm ${tmpFile}" >/dev/null 2>&1
        then
            echo -en "${RED}WRITE\t"
            echo -n ": ${share} : ${tdir}"
            echo -e "${RST}"
        else
            echo -en "${YELLOW}READ\t"
            echo -n ": ${share} : ${tdir}"
            echo -e "${RST}"
        fi
    }

    shareList=$($smbclient -g -t 2 -L "$host" -U "${user}%${pass}" 2>/dev/null | awk -F'|' '$1 == "Disk" {print $2}')

    # Write file
    tmpFile=tmp_$$.tmp

    cd "${TMPDIR:-/tmp}"
    touch ${tmpFile}

    for share in $shareList
    do
        if $smbclient "//${host}/${share}/" -U "${user}%${pass}" -c "lcd" >/dev/null 2>&1
        then
            # Current dir
            checkReadWritePerm "${share}" "." "${tmpFile}"

            # Recursive dir
            $smbclient "//${host}/${share}/" -U "${user}%${pass}"  -c "recurse;dir" | grep -E ^'\\' 2>/dev/null | 	while IFS= read -r line
            do
                checkReadWritePerm "${share}" "${line}" "${tmpFile}"
            done
        else
            echo -en "${GRAY}NONE\t"
            echo -n ": ${share}"
            echo -e "${RST}"
        fi
    done

    rm -f ${tmpFile}

}

scanSmb(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name" '. ' cyan
    host="$1"
    port="${2:-139,445}"
    outfile="$prefix-${host}-${func_name}.txt"


    centerPrint "nbtscan" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd nbtscan -r "$host" | tee -a "$outfile"
    
    centerPrint "nmblookup" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd nmblookup -A "$host" | tee -a "$outfile"
    
    centerPrint "smbclient" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd smbclient -L \\"$host" -N | tee -a "$outfile"

    centerPrint "crackmapexec" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd crackmapexec smb "$host" -u anonymouse -p anonymous | tee -a "$outfile"
    
    centerPrint "smbmap" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd smbmap -H "$host" | tee -a "$outfile" | tee -a "$outfile"
    
    centerPrint "enum4linux" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd enum4linux -a "$host" | tee -a "$outfile"
    
    centerPrint "nmap" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd nmap -p $port --script "smb-vuln*,nbst*" "$host" | tee -a "$outfile"

    centerPrint "smbcheckperms" ' .. ' | tee -a "$outfile"
    $proxycmd smbCheckPerm "$host" "$user" "$pass"

    # centerPrint "rpcclient" ' .. ' | tee -a "$outfile"
    # sudo rpcclient -U ""  $host | tee -a "$outfile"

    # smbclient -L //192.168.93.6 -c 'recurse; ls' 2>/dev/null 
    shares=( $($proxycmd $sudocmd smbclient -L //$host -N 2>/dev/null | grep -Ei Disk | tr -s ' ' | cut -d ' ' -f1 | sed -e "s/\t//g") )
    for share in ${shares[@]}; do
        centerPrint "Files in //$host/$share:" " . .  "
        smbclient "//$host/$share" -U% -c 'recurse; ls' 2>/dev/null | grep -v '^\.'
    echo
    done
    
    centerPrint "msfconsole" ' .. ' | tee -a "$outfile"
    $proxycmd $sudocmd msfconsole -q -x "use auxiliary/scanner/smb/smb_enumusers; set RHOST $host; run; exit -y" | tee -a "$outfile"

    $proxycmd $sudocmd smbmap -H $host -r --depth 30

    $proxycmd $sudocmd xdg-open "smb://$host" &
}

scanWordpress(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="${2:-80,443}"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-80} --script http-wordpress-enum.nse -oN "$outfile" "$host"

    $proxycmd $sudocmd sqlmap -u "http://$host/wp/wp-content/plugins/wp-autosuggest/autosuggest.php?wpas_action=query&wpas_keys=1" --technique BT --dbms MYSQL --risk 3 --level 5 -p wpas_keys --tamper space2comment --sql-shell | tee -a "$outfile" 

    $proxycmd $sudocmd wpscan --url $host --api-token 0x1SMGS2c0JJefCKFjVv3Fhoq5rbYgHP6BFWtQ9LU3M --enumerate vp --enumerate u --plugins-detection aggressive | tee -a "$outfile" 
}

scanSsh(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    # sudo nmap -p ${ports:-22} --script ssh-brute --script-args userdb=users.lst,passdb=pass.lst --script-args ssh-brute.timeout=4s  -oN "$outfile" "$host"

    msfconsole -q -x "use auxiliary/scanner/ssh/ssh_enumusers; set RHOST $host; set USER_FILE /usr/share/wordlists/legion/ssh-user.txt;run; exit -y " | tee -a "$outfile"

    echo 123 | nc -vn $host 22 | tee -a "$outfile"

    ssh-audit $host | tee -a "$outfile"

    ssh-keyscan -t rsa $host -p ${ports:-22} | tee -a "$outfile"
}

scanFtp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"
    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-21} --script ftp-anon.nse  -oN "$outfile" "$host" -vvv
    $proxycmd $sudocmd msfconsole -q -x "use auxiliary/scanner/ftp/anonymous; set RHOST $host; set THREADS 55; exploit; exit -y " | tee -a "$outfile"
    echo "FAÇA ISSO: ftp anonymous@$host "
    $proxycmd $sudocmd ftp anonymous@$host
}

scanDrupal(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-80} --script http-drupal-enum.nse -oN "$outfile" "$host"
}

scanJoomla(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${port:=80} --script http-joomla-brute.nse -oN "$outfile" "$host"

    # using joomscan
    $proxycmd $sudocmd joomscan -u $host | tee -a "$outfile"
}

scanMywebmin(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-10000} --script http-webmin-enum.nse -oN "$outfile" "$host"
}

scanMyphpadmin(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-80} --script http-phpmyadmin-dir-traversal.nse -oN "$outfile" "$host"
}

scanRpc(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-111} --script rpcinfo.nse -oN "$outfile" "$host"
    
}

scanRdp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-3389} --script rdp-enum-encryption.nse -oN "$outfile" "$host"
    $proxycmd $sudocmd rdesktop $host -u "" &
}

scanVnc(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-5900} --script vnc-info.nse -oN "$outfile" "$host"
}

scanLxc(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-80} --script http-lxc-console.nse -oN "$outfile" "$host"
}

scanDocker(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-2375} --script docker-version.nse -oN "$outfile" "$host"
}

scanDns(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-53} --script dns-zone-transfer.nse -oN "$outfile" "$host"
}

scanSmtp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-25} --script smtp-commands.nse -oN "$outfile" "$host"
}

scanImap(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-143} --script imap-capabilities.nse -oN "$outfile" "$host"
}

scanPop(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-110} --script pop3-capabilities.nse -oN "$outfile" "$host"
}

scanModbus(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-502} --script modbus-discover.nse -oN "$outfile" "$host"
}

scanTelnet(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-23} --script telnet-encryption.nse -oN "$outfile" "$host"
}

scanDhcp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-67} --script dhcp-discover.nse -oN "$outfile" "$host"
}

scanNntp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-119} --script nntp-ntlm-info.nse -oN "$outfile" "$host"
}

scanNtp(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-123} --script ntp-info.nse -oN "$outfile" "$host"
}

scanNetbios(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${ports:-137,138,139,445} --script smb-os-discovery.nse -oN "$outfile" "$host"
}

scanAd(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${2:-389,636} --script ldap-search.nse -oN "$outfile" "$host"
}

scanIrc(){
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    port="$2"

    outfile="$prefix-${func_name}-${host}.txt"
    $proxycmd $sudocmd nmap -p ${2:-6667} --script irc-info.nse -oN "$outfile" "$host"
}

scanHttp(){
    local func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    local host="${1}"
    local port="${2}"
    local subdir=${3}
    local url="${4}"
    local wordlist=${5}
    local outfile="$prefix-${func_name}-${host}-${port}"
    
    firefox "http://$host:$port" &
    $proxycmd $sudocmd nmap -p ${2:-80} --script http-enum.nse,http-apache-server-status.nse -oN "$outfile.txt" "$host"

    $proxycmd $sudocmd nikto -h "$host" -maxtime 500s -output "$outfile-nikto.txt"

    $proxycmd $sudocmd nikto -h "$host" -useragent "Edge/91.0.864.59" -maxtime 500s -Tuning 9 -output "$outfile-nikto.txt"

    # run all tests of nikto except the ones that take too long
    $proxycmd $sudocmd nikto -h "$host" -maxtime 500s -output "$outfile-nikto.txt" -Plugins 'apacheusers,auth,authmsg,backdoor,brotli,cookies,debug,dict,drupal,httpoptions,httpserverheaders,httpstatus,httptraversal,methods,ms10-070,multipleindex,mutillidae,nsfocus,oracle9i,oscommerce,paths,phpself,xss,robots,shellshock,sitefiles,soap,targets,templates,vbulletin,vtiger,webdav,webobjects,whisker,wordpress' -output "$outfile-nikto_plugins.txt"

    $proxycmd $sudocmd nikto -h "$host" -maxtime 500s -output "$outfile-nikto.txt"

    $proxycmd $sudocmd curl -v $host/iahsidhiashd.asp | tee -a "$outfile.txt"
    
    $proxycmd $sudocmd curl -v $host/asdahsihaihsd.php | tee -a "$outfile.txt"
    
    
    # enumeracao manual
    # enumeracao nikito gobuster, applicacoes
    #   # ver se os métodos, atentar para o PUT
    # bruteforte hidra e na mao
    # vuln servidor e aplicacoes web
    # sql injection
    # codigo fonte
    # seguir links
    # enumerar pelo burb
    # cookies
    # github, ver versoes antigas da aplicacao
    # ver phpinfo
    # robots
    # verificar tercnologia
    # procurar pontos de injecao (upload)
    # cgi-bin
    # ver credenciais padrao
}

scanHttps(){
    local func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    local host="${1}"
    local port="${2}"
    local subdir=${3}
    local url="${4}"
    local wordlist=${5}
    local outfile="$prefix-${func_name}-${host}-${port}"

    $proxycmd $sudocmd firefox "https://$host:$port/$subdir" &
    set -x
    $proxycmd $sudocmd nmap -p ${2:-443} --script http-enum.nse,http-apache-server-status.nse,ssl-cert,ssl-enum-ciphers,ssl-heartbleed,http-vuln-cve2014-8877,http-cookie-flags,http-security-headers,http-title,http-methods -oN "$outfile.nmap" "$host"
    set +x 
    outfile_nikto="krep-$func_name-${host}-${port}-nikto"

    set -x
    $proxycmd $sudocmd nikto -h "$host" -p $port -ssl -maxtime 500s -output "$outfile_nikto.txt"

    $proxycmd $sudocmd curl -v $host/iahsidhiashd.asp | tee -a "$outfile.txt"
    $proxycmd $sudocmd curl -v $host/asdahsihaihsd.php | tee -a "$outfile.txt"
    set +x
    # Scan service webmin for vulnerabilities
}

scanDir() {
    local func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    local host="${1}"
    local port="${2}"
    local subdir=${3}
    local url="${4}"
    local wordlist=${5}
    local outfile="krep-$func_name-${host}-${port}"

    set -x
    # dirb "$url" "$wordlist" -a "Microsoft-IIS/10.0" -r -S -N 404 -t 100 -c 100 -R 3 -o "$outfile-dirb.txt"

    # asp,json,pdf,php,txt
    $proxycmd $sudocmd feroxbuster -u "$url" -w $wordlist -t 10 -a lidesec -k --collect-extensions -x aspx -d 2 --filter-status 404,400 -n --dont-filter -o "$outfile-feroxbuster.txt"

    $proxycmd $sudocmd dirb "$url" "$wordlist" -o "$outfile-dirb.txt"


    $proxycmd $sudocmd gobuster dir -u "$url" -w $wordlist -o "$outfile-gobuster.txt" -t 100 -c 100 -r -e -k -x pdf,js,html,php,asp,txt,json

    # do a simple and fast scan in wfuzz to get what feroxbuster couldn't find
    # wfuzz -c -z file,"$wordlist" -f "$outfile-wfuzz.txt" "$url/FUZZ"
    set +x

    # Get only dirs from feroxbuster output up to second   level
    cat "$outfile-feroxbuster.txt" | grep ^200 | grep -Ei "/$" | tr -s ' ' | cut -d ' ' -f6 | grep -Ev "^$url/$" > "$outfile-feroxbuster_dirs.txt"
    # if there is any dir in feroxbuster_dir, do a second level simple scan
    if [ -s "$outfile-feroxbuster_dirs.txt" ]; then
        for i in $(cat "$outfile-feroxbuster_dirs.txt"); do 
        $proxycmd $sudocmd feroxbuster -u "$i" -w ${wordlist:='/usr/share/wordlists/dirb/big.txt'} -x pdf,js,html,php,asp,txt,json -r -o "$outfile-feroxbuster_level2.txt"; done
    fi

    webfiles=( $(cat "$outfile-feroxbuster.txt" | grep ^200 | grep -Ei "htm|php|asp|xml|/$"  | tr -s ' ' | cut -d ' ' -f6 ) $(cat "$outfile-gobuster.txt" | grep "Status: 200" | grep -Ei "htm|php|asp|xml|/$" | tr -s ' ' | cut -d ' ' -f1) )

    for i in ${webfiles[@]}; do
        echo "---------- $i" | tee -a "$outfile-sitedump.txt"; curl "$i" | tee -a "$outfile-sitedump.txt";
        curl -v $host | tee -a "$outfile.txt"
    done
    # Make bag of words from html file, with comments too
    cat "$outfile-sitedump.txt" | grep -Eo "\w{3,}" | sort -u > "$outfile-wordlist.txt"
}

# Nmap Scans
scanVuln(){
    func_name="${FUNCNAME[0]}"
    host="$1"
    ports="$2"
    centerPrint "$func_name  - $ports"
    outfile="krep-$func_name-${host}-$ports.nmap"
    set -x
    $proxycmd $sudocmd nmap -A --reason \
    ${opt_scanfast} ${opt_unprivileged} ${opt_anon} \
    -p "$ports" \
    -sV \
    --script=vulners \
    -oN "$outfile" \
    $host
    set +x
}
bannerGrab(){
    func_name="${FUNCNAME[0]}"
    host=$1;
    ports=$2
    centerPrint "$func_name - $ports"
    outfile="krep-$func_name-${host}-$ports.nmap"
    outfile_nc="krep-$func_name-${host}-nc_banner.txt"

    set -x
    $proxycmd $sudocmd nmap -A --reason \
    ${opt_scanfast} ${opt_unprivileged} ${opt_anon} -O \
    -sC \
    -p "${ports}" \
    -sV \
    --script=banner* \
    -oN "$outfile" \
    $host
    set +x
# --script-args
    echo NC > "$outfile_nc"
    for i in ${ports//,/ }; do
        echo bannergrab | nc -v -n -w 1 $1 $i
    done >> "$outfile_nc"
}

## BASIC SCAN
scanNetwork () {
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    network="$1"
    outfile="$prefix-${network}-${func_name}.nmap"
    outfile_hostsup=$prefix-$network-hosts_up.txt

    $proxycmd $sudocmd nmap \
    -sn "$network" ${opt_scanfast} ${opt_unprivileged} ${opt_anon} -oG "$outfile"
    cat "$outfile" | awk '/Up$/{print $2}' > "$outfile_hostsup"
}
scanHost () {
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    outfile="$prefix-${func_name}-${host}"
        
    # Faz o scan 
    # check if nmap exists
    if ! [ -x "$(command -v nmap)" ]; then
        echo "Nmap não disponível"
        $proxycmd $sudocmd nc -nvv -w1 -z $host 1-10000 | tee -a "$outfile.txt"
    else
        set -x
        $proxycmd $sudocmd nmap \
        ${opt_scanfast}  ${opt_anon} ${opt_unprivileged} -p- \
        -oG "$outfile.nmap" \
        "$host"
        set +x

        cat "$outfile.nmap" | grep -oE " [0-9]+/[^ ]+" | cut -d '/' -f5 > "$outfile-services".txt
        cat "$outfile.nmap" | grep -oE " [0-9]+/[^ ]+" | cut -d '/' -f1 > "$outfile-ports".txt
    fi
}

scanPort () {
    func_name="${FUNCNAME[0]}"
    centerPrint "$func_name"
    host="$1"
    ports="$2"
    types="${types:-default}"
    outfile="$prefix-${host}-${func_name}-$ports.nmap"

    echo $types
    for i in ${types//,/ }; do
        case $i in
            vuln)
                scanVuln $host $ports
            ;;
            banner)
                bannerGrab $host $ports
            ;;
            default)
                $proxycmd $sudocmd nmap -A ${opt_scanfast} ${opt_unprivileged} ${opt_anon} --reason \
                --host-timeout 5m \
                -p "$ports" \
                -sV \
                -oN "$outfile" \
                "$host"
            ;;
        esac
    done

    
}
scanServices(){
    func_name="${FUNCNAME[0]}"
    local services="$2"
    centerPrint "$func_name - $services"
    local host="$1"
    local port="$3"
    local outfile="$prefix-$func_name-${1}-$port.txt"
    local extraargs=$4

    for i in ${services//,/ }; do
        case $i in
            smb)
                scanSmb $host $port
            ;;
            ftp)
                scanFtp $host $port
            ;;
            ssh)
                scanSsh $host $port
            ;;
            wordpress)
                scanWordpress $host $port
            ;;
            drupal)
                scanDrupal $host $port
            ;;
            joomla)
                scanJoomla $host $port
            ;;
            mywebmin)
                scanMywebmin $host $port
            ;;
            myphpadmin)
                scanMyphpadmin $host $port
            ;;
            rdp|msrpc|rpc)
                scanRdp $host $port
            ;;
            vnc)
                scanVnc $host $port
            ;;
            lxc)
                scanLxc $host $port
            ;;
            docker)
                scanDocker $host $port
            ;;
            dns)
                scanDns $host $port
            ;;
            smtp)
                scanSmtp $host $port
            ;;
            imap)
                scanImap $host $port
            ;;
            pop)
                scanPop $host $port
            ;;
            modbus)
                scanModbus $host $port
            ;;
            telnet)
                scanTelnet $host $port
            ;;
            dhcp)
                scanDhcp $host $port
            ;;
            nntp)
                scanNntp $host $port
            ;;
            ntp)
                scanNtp $host $port
            ;;
            netbios)
                scanNetbios $host $port
            ;;
            ad)
                scanAd $host $port
            ;;
            irc)
                scanIrc $host $port
            ;;
            dir)
                scanDir ${host:-"192.168.1.1"} ${port:-80}  ${extraargs:-"/"} "${url:-"http://$host:$port$extraargs"}" ${wordlist:='/usr/share/wordlists/dirb/big.txt'}
            ;;
            http)
                scanHttp ${host:-"192.168.1.1"} ${port:-80}  ${extraargs:-"/"} "${url:-"http://$host:$port$extraargs"}" ${wordlist:='/usr/share/wordlists/dirb/big.txt'}
            ;;
            https)
                scanHttps ${host:-"192.168.1.1"} ${port:-443}  ${extraargs:-"/"} "${url:-"http://$host:$port$extraargs"}" ${wordlist:='/usr/share/wordlists/dirb/big.txt'}
            ;;
            *)
                echo "Serviço $i não encontrado"
            ;;
        esac
    done
}

scanAll () {
    centerPrint "${FUNCNAME[0]}" '-' green
    host=$1

    # inicia o scan do host e
    # Verifica se já foi realizado o scan
    # debugCheckPoint -p host prefix
    [ ! -f "$prefix-scanHost-$host.nmap" ] && scanHost $host
    
    # Verifica se tem portas disponíveis
    cat "$prefix-scanHost-$host-ports.txt"
    echo ok
    [ ! -f "$prefix-scanHost-$host-ports.txt" ] || \
    [ "$(cat "$prefix-scanHost-$host-ports.txt" | wc -l )" -le 0 ] && \
    exitError "Nenhuma porta encontrada"

    # Procura agressivamente com banner grabbing
    portslist="$(cat "$prefix-scanHost-$host-ports.txt" | sort | uniq | awk -v ORS=, '{ print $1 }' | sed 's/,$/\n/' )"
    [ ! -f "$prefix-bannerGrab-$host-$portslist.nmap" ] && bannerGrab $host "${portslist}"
    # Agora busca somente as vulnerabilidades
    [ ! -f "$prefix-scanVuln-$host-$portslist.nmap" ] && scanVuln $host "${portslist}"

    # scan services
    serviceslist="$(cat "$prefix-scanHost-$host-services.txt" | sort | uniq | awk -v ORS=, '{ print $1 }' | sed 's/,$/\n/' )"
    for i in $(cat "$prefix-scanHost-$host-services.txt"); do
        [ ! -f "$prefix-scan${i^}-$host.txt" ] && scanServices $host "${i}" &
    done
}

# Fim_Declaracao_funcoes
# Imprime o Menu
printHeader -q
# Imprime o
echo -e "Usage:\n ${help_examples[*]}"
# checkDependencies ${help_dependencies} || exitError "Error while checking dependencies"
# Pega os argumentos

OPTIONS=$(getopt -o $help_synopsys_args --long $help_synopsys_long -- "$@")
# Checking if getopt had issues
[ $? -ne 0 ] && exitError "Error while parsing arguments, nao deu"

# Executa o modo interativo
if [[ -z "${*}" ]]; then
    case $(printQuestion -m "Scan Network" "Scan Host" "Scan Port" "Scan All" "Scan Services") in
    # Scan Network
    "Scan Network")
        netw=$(printQuestion -r "Digite a rede ou o range")
        scanNetwork $netw
    ;;
    "Scan Host")
        host=$(printQuestion -r "Digite o host")
        scanHost $host
    ;;
   "Scan Port")
        host=$(printQuestion -r "Digite o host")
        port=$(printQuestion -r "Digite o port")
        scanPort $host $port
    ;;
    "Scan All")
        host=$(printQuestion -r "Digite o host")
        scanAll $host
    ;;
    "Scan Services")
        host=$(printQuestion -r "Digite o host")
        services=$(printQuestion -r "Digite os serviços")
        port=$(printQuestion -r "Digite a(s) porta(s) (opcional)")
        scanServices $host $services $ports $extra
    ;;
    *)
        echo "Opcao inválida"
        exitError "The Dumber you are the less you work.   ... Kmrlynkx"
        ;;
    esac
fi

eval set -- "$OPTIONS"
# Gerencia as opções de linha de comando usando get opts
while true; do
  case "${1}" in
    # help
    $(parseArg ${arg[1]})|$(parseArg ${arg[1]} -l))
        statusOptions['printhelp']=true; shift
        ;;
    #man
    $(parseArg ${arg[2]})|$(parseArg ${arg[2]} -l))
    statusOptions['printmanual']=true; shift
        ;;
    # show version
    $(parseArg ${arg[3]})|$(parseArg ${arg[3]} -l))
        statusOptions['showversion']=true; shift
        ;;
    #network address
    $(parseArg ${arg[4]})|$(parseArg ${arg[4]} -l))
        netadd=$2; shift 2
    ;;
    #host
    $(parseArg ${arg[5]})|$(parseArg ${arg[5]} -l))
        host=$2; shift 2
    ;;
    #ports
    $(parseArg ${arg[6]})|$(parseArg ${arg[6]} -l))
        port=$2; shift 2
    ;;
    #all
    $(parseArg ${arg[7]})|$(parseArg ${arg[7]} -l))
        statusOptions['scanall']=true; shift
    ;;
    #fast
    $(parseArg ${arg[8]})|$(parseArg ${arg[8]} -l))
        statusOptions['scanfast']=true; shift
    ;;
    #services
    $(parseArg ${arg[9]})|$(parseArg ${arg[9]} -l))
        services=$2; shift 2
    ;;
    # anon
    $(parseArg ${arg[10]})|$(parseArg ${arg[10]} -l))
        statusOptions['anon']=true; shift 1
    ;;
    #types
    $(parseArg ${arg[11]})|$(parseArg ${arg[11]} -l))
        export types="$2"; shift 2
    ;;
    #url
    $(parseArg ${arg[12]})|$(parseArg ${arg[12]} -l))
        export url="$2"; shift 2
    ;;
    #wordlist
    $(parseArg ${arg[13]})|$(parseArg ${arg[13]} -l))
        export wordlist="$2"; shift 2
    ;;
    # unprivileged
    $(parseArg ${arg[14]})|$(parseArg ${arg[14]} -l))
        statusOptions['unprivileged']=true; shift 1
    ;;
    # verbose
    $(parseArg ${arg[15]})|$(parseArg ${arg[15]} -l))
        ((verbosity++)); shift 1
    ;;
    $(parseArg ${arg[16]})|$(parseArg ${arg[16]} -l))
        extra="$2"; shift 2
    ;;
    #fast
    $(parseArg ${arg[17]})|$(parseArg ${arg[17]} -l))
        statusOptions['proxy']=true; shift
    ;;
    --)
        shift 2
        break
        ;;
    *)
        exitError "Invalid option: -$OPTARG"
        ;;
  esac
done

# Verifica se o scan deve ser rápido
[ "${statusOptions['scanfast']}" = false ] && opt_scanfast="" || opt_scanfast="-Pn -vv -T 3 --host-timeout 5m --max-rtt-timeout 200ms --min-rate 500"
# verifica se deve ser anon
[ "${statusOptions['anon']}" = false ] && opt_anon="" || opt_anon=""$(generateDecoys)" --source-port=53 --ttl 128 --spoof-mac 0"
# verifica se faz via proxychains
[ "${statusOptions['proxy']}" = false ] && proxycmd="" || proxycmd="proxychains -q"
# Verifica se deve ser nao privilegiado
[ "${statusOptions['unprivileged']}" == false ] && { sudocmd="sudo"; opt_unprivileged="-sS -O"; } || { sudocmd=""; opt_unprivileged="-sT --unprivileged"; }

echo "$status_printHelp"
[ "${statusOptions['printhelp']}" = true ] && printHelp
[ "${statusOptions['showversion']}" = true ] && echo Version=$help_version
[ "${statusOptions['printmanual']}" = true ] && printHelp -m

if [ "${statusOptions['scanall']}" = true ] && [ -n "$host" ]; then
    scanAll "$host"
elif [ -n "$host" ] && [ -z "$port" ] && [ -z "$services" ]; then
    scanHost "$host"
elif [ -n "$host" ] && [ -n "$services" ]; then
    scanServices "$host" "$services" "$port" "$extra"
elif [ -n "$host" ] && [ -n "$port" ]; then
    scanPort "$host" "$port"
elif [ -n "$netadd" ] && [ -z "$host" ] && [ -z "$port" ]; then
    scanNetwork "$netadd"
fi

# sl -e -a
# curl parrot.live
# echo "Opcao inválida"
# exitError "The Dumber you are the less you work.   ... Kmrlynkx"