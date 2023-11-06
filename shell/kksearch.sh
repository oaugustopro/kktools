#!/bin/bash
# TODO
# - search wordlist com head -n 1 em todas
# -l local, busca nos arquivos
# -e busca exploit
# -t tool, busca ferramenta
# -c comando, busca comando
# -o busca e abre o arquivo com cat, bat, grc cat, etc...
# -w wordlist

# END TODO

## Import Libs
source libkmrgobash.sh || { echo "Error while loading source files"; exit 1; }
this=$(basename $0)

### Arguments
### Help variables
help_short_description="Search tool"
help_version="0.3"
help_dependencies="rg w3m ddgr pygmentize lynx searchsploit msfconsole"
help_notes="Requer paciencia ao quadrado."

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

i=4 arg[$i]="-l:|--local:"; argument_name[$i]="local find"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, procura no conteudo de arquivos ascii no diretorio atual, não recursivamente.\n"

i=5 arg[$i]="-e:|--exploit:"; argument_name[$i]="exploit"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, busca em várias bases de exploits.\n"

i=6 arg[$i]="-t:|--tool:"; argument_name[$i]="tool"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, busca por ferramenta para o argumento.\n"

i=7 arg[$i]="-d|--download"; argument_name[$i]="download"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, baixa se tiver um arquivo.\n"

i=8 arg[$i]="-o|--open"; argument_name[$i]="open"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, abre o link se encontrar.\n"

i=9 arg[$i]="-c:|--command:"; argument_name[$i]="command"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, busca um comando.\n"

i=10 arg[$i]="-v|--verbose"; argument_name[$i]="verbose"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, para q o nmap nao rode usando pacotes icmp. Útil quando estiver em algum tipo de proxy.\n"

i=11 arg[$i]="-w:|--wordlist:"; argument_name[$i]="wordlist"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, busca as wordlists.\n"

i=12 arg[$i]="-b:|--bin:"; argument_name[$i]="bin"; help_options[$i]="${arg[$i]//:/}
\t${argument_name[$i]}, busca binarios em GTFObins, DLLs, Apps Windows, etc.\n"

## EXAMPLES
i=1; help_examples[$i]="$this -d -e apache 2.23
\t Busca um exploit para o apache 2.23 e baixa se encontrar."

i=1; help_examples[$i]="$this -c "hydra"
\t Busca comandos emitidos nos histórico, notas, scripts e funções declaradas."

i=1; help_examples[$i]="$this -t "hydra"
\t Busca uma ferramenta para o apache 2.23 e baixa se encontrar."

i=1; help_examples[$i]="$this -l "ssh"
\t Busca nos arquivos locais para o apache 2.23 e baixa se encontrar."

i=1; help_examples[$i]="$this -b "awk"
\t Busca um binário no gtobins, lolbas, wadcoms e hicjacklibs."
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
#################################
### Declaracao_variaveis
declare -A statusOptions
statusOptions['showversion']=false
statusOptions['printhelp']=false
statusOptions['printmanual']=false
export prefix="krep"
### Fim_Declaracao_variaveis

#################################
### Declaracao_funcoes

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

searchTools(){
    ddgr -x --np kali tool $query linux
    lynx --dump --listonly "https://www.google.com/search?client=firefox-b-d&q=tool kali linux $query" | grep "url?" | sed -e "s/\(.*url?q=\)/\1/" | grep -i http
}

searchWordlist(){
    grep --color=auto -i "$query" "$HOME"/AppStorage/Security/Wordlists/wordlists_kali.txt
}

searchLocal(){
    query="$1"
    GREP_OPTIONS='--color=always'
    GREP_COLOR='1;35;40'

    # find $PWD/ -type f -exec sh -c 'if [ "$(file $1)" = "$1: ASCII text" ]; then grep --color=auto -A3 -B3 -EinH '.*$1.*' $1; fi' _ {} ";"

    rg --color=auto -A2 -B2 -i "$query" .
    # grep --color=auto -A2 -B2 -EiHn $@
}

searchBin(){
    "$HOME"/AppExec/System/Security/gtfoblookup/0-starter.sh gtfobins search "${query:='find'}"
}

searchExploit (){
    query="$1"
    # go-exploitdb search --type CVE --param "$query"
    searchsploit "$query"
    msfconsole -q -x "search $query; exit -y"
    ddgr -x --np exploit $query git
    lynx --dump --listonly "https://www.google.com/search?client=firefox-b-d&q=exploit $query" | grep "url?" | sed -e "s/\(.*url?q=\)/\1/" | grep -i http
    xdg-open "https://www.google.com/search?client=firefox-b-d&q=exploit $query" &
}

searchCommand (){
    comando="$1"
    centerPrint "Funções declaradas" 'find ' cyan
    declare -F | cut -d ' ' -f3- | grep "$comando"
    centerPrint "Histórico" 'find ' cyan
    grep --color=auto -nH -A 1 -B 1 "$1" ~/.bash_history
    centerPrint "Bin dir" 'find ' cyan
    grep --color=auto -nirH -A 1 -B 1 "$1" ~/bin/shell/*.sh
    centerPrint "Notas" 'find ' cyan
    find ~/Documents/Notes/Personal/Technology -name *.org -o -name *.md -exec grep --color=auto -nH -A 1 -B 1 "$comando" "{}" \;
    find ~/Documents/Notes/Academic/Computers -name *.org -o -name *.md -exec grep --color=auto -nH -A 1 -B 1 "$comando" "{}" \;
}

### Fim_Declaracao_funcoes
###################################

###################################
### MAIN

# Imprime o Menu4
printHeader -q
# Imprime o Usage
echo -e "Usage:\n ${help_examples[*]}"
# Pega os argumentos
OPTIONS=$(getopt -o $help_synopsys_args --long $help_synopsys_long -- "$@")
# Checking if getopt had issues
[ $? -ne 0 ] && exitError "Error while parsing arguments, nao deu"

[[ $(grep -i $(basename $0) \"$HOME/*history\" 2>/dev/null) != "" ]] && checkDependencies "${help_dependencies[@]}"

# Executa o modo interativo
if [[ -z "${*}" ]]; then
    case $(printQuestion -m "Search Local" "Search Command" "Search Exploit" "Search Tool" "Search Wordlist" "Search Bin") in
    # Scan Network
    "Search Local")
        query=$(printQuestion -r "Digite a sua busca")
        searchLocal "$query"
    ;;
    "Search Command")
        query=$(printQuestion -r "Digite a sua busca")
        searchCommand "$query"
    ;;
   "Search Exploit")
        query=$(printQuestion -r "Digite a sua busca")
        searchExploit "$query"
    ;;
    "Search Tool")
        query=$(printQuestion -r "Digite a sua busca")
        searchTools "$query"
    ;;
    "Search Wordlist")
        query=$(printQuestion -r "Digite a sua busca")
        searchWordlist "$query"
    ;;
    "Search Bin")
        query=$(printQuestion -r "Digite a sua busca")
        searchWordlist "$query"
    ;;
    *)
        echo "Opcao inválida"
        exitError "The Dumber you are the less you work.   ... Kmrlynkx"
        ;;
    esac
fi

eval set -- "$OPTIONS"
# Gerencia as opções de linha de comando usando get opts
j=0
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
    # scan local
    $(parseArg ${arg[4]})|$(parseArg ${arg[4]} -l))
        execute[j]=local
        query="$2"; shift 2
    ;;
    # exploit
    $(parseArg ${arg[5]})|$(parseArg ${arg[5]} -l))
        execute[j]=exploit
        query="$2"; shift 2
    ;;
    # tool
    $(parseArg ${arg[6]})|$(parseArg ${arg[6]} -l))
        execute[j]=tool
        query=$2; shift 2
    ;;
    # download
    $(parseArg ${arg[7]})|$(parseArg ${arg[7]} -l))
        statusOptions['download']=true; shift
    ;;
    # open
    $(parseArg ${arg[8]})|$(parseArg ${arg[8]} -l))
        statusOptions['open']=true; shift
    ;;
    # command
    $(parseArg ${arg[9]})|$(parseArg ${arg[9]} -l))
        execute[j]=command
        query=$2; shift 2
    ;;
    # verbose
    $(parseArg ${arg[10]})|$(parseArg ${arg[10]} -l))
        ((verbosity++)); shift 1
    ;;
    # wordlist
    $(parseArg ${arg[11]})|$(parseArg ${arg[11]} -l))
        execute[j]=wordlist
        query=$2; shift 2
    ;;
    # bin
    $(parseArg ${arg[12]})|$(parseArg ${arg[12]} -l))
        execute[j]=bin
        query=$2; shift 2
    ;;
    --)
        shift 2
        break
        ;;
    *)
        exitError "Invalid option: -$OPTARG"
        ;;
  esac
  ((j++))
done

# Verifica se o scan deve ser rápido
[ "${statusOptions['printhelp']}" = true ] && printHelp
[ "${statusOptions['showversion']}" = true ] && echo Version=$help_version
[ "${statusOptions['printmanual']}" = true ] && printHelp -m

for i in ${execute[@]}; do
centerPrint "${execute[i]}" ' .. '
    case $i in
    'tool')
        searchTools $query
    ;;
    'local')
        searchLocal "$query"
    ;;
    'command')
        searchCommand "$query"
    ;;
    'exploit')
        searchExploit "$query"
    ;;
    'wordlist')
        searchWordlist "$query"
    ;;
    'bin')
        searchBin "$query"
    ;;
    esac
done