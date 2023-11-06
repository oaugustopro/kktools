#!/bin/bash
setColors () {
	declare -A colorType=( ['bold']=1 ['dim']=2 ['underline']=4 ['blink']=5 ['reverse']=7 ['hidden']=8 ['def']=0 )
	declare -A colorArray=( ['bg_def']=49 ['bg_black']=40 ['bg_red']=41 ['bg_green']=42 ['bg_yellow']=43 ['bg_blue']=44 ['bg_magenta']=45 ['bg_cyan']=46 ['bg_grey_light']=47 ['bg_grey_dark']=100 ['bg_red_light']=101 ['bg_green_light']=102 ['bg_yellow_light']=103 ['bg_blue_light']=104  ['bg_magenta_light']=105 ['bg_cyan_light']=106 ['bg_white']=107 ['fg_def']=39 ['black']=30 ['red']=31 ['green']=32 ['yellow']=33 ['blue']=34 ['magenta']=35 ['cyan']=36 ['grey_light']=37 ['grey_dark']=90 ['red_light']=91 ['green_light']=92 ['yellow_light']=93 ['blAnimationue_light']=94 ['magenta_light']=95 ['cyan_light']=96 ['white']=97 ['def']=0 )
	def='\033[0;00m'
	for i in "${!colorArray[@]}"; do
		for j in "${!colorType[@]}"; do
			[ "$j" = 'def' ] && local attribute='' || local attribute="_$j"
			eval "${i}${attribute}"="'\033['${colorType[$j]}';'${colorArray[$i]}m" # Declara variaveis de forma dinâmica
		done
	done
}
setColors

printLogo () {
	local draw_ghostbuster='H4sIAHa8tFwAA3WTSQ6DMAxF9zmFxaawMD5BuQKrIhaWfIuev3HiDE7ol0CBvI+nAFDEAeD5Abgt
RRBRxG3XPbQFKaIaMXWvQPbR7W7i7+7hHePbNS7OfPWwCh1OBqs+6b6VrRIgeLrxpi0mXenBkQ0E
ZjlrhExqNaPFHGDVumSUFzHPYLlF6IHP4tR+PAKkKeR8/xo0Rq1Aw3AckPqUj27iKUDOVzQMvVNm
jGn6YlFmHuAVk7GNUkx0ac/4kfddbfVzbT24Mzc6qBsl9wGOySCzo3hKI3parBDPA9ZD51XagdPv
0EqZRA//zrJcM3gtS/gBs0wCrZ8DAAA='
	local logo_kmrgo_digital_small='H4sIANO9tFwAA5OONrA2tDY2sbY0ydXWhUPpaINcLmkkuZrsmtyaopp0kJgxkJtfA1dijKkTAGOI
sO9WAAAA'
	local logo_krmgo_mono12_big='H4sIAFbAtFwAA82WMW7DMAxF91whi49Qx0kAQUfpGXwHotCgoUMGI+j5dJLWLWWJn5IqJ0NreJFA
PZKfpOywvIeF/uV7O4Tlbdj9fB36Pnh8fbGjnUZrxjncHS8nayZezs+BmeR5ebLmxMsnwRlpXV6t
uW5g3jtbc16zSFYXay6rVbgTR9AOU/OTRkz3iu7KaEV3JboHumTFMiW7PXTJitEmO6b7Ep2TgiJk
ZCmJU4Knku8uoIftCIWwZXrVEtIWyKABMmk2hfO1IrWjQxrHRxUFQOjMk+7jZu22GW6XrKQvbFdk
krLLTo4z3ncZtHMV6rVj6ckVBG72lPRCR+wwmPhWAsVyzX0CVaZiKEwVFcshL8XyjO7PHvrXdVyR
VCoBeyXtT/cXJTt2Iqcr8wNo1JpguywgRBHx4jbBArlEQftHuhjz1XQ+F2X95VGh9XwGSKuUf8c7
Xevn5+Dy1z9Ttffj8AnTtnrdAgoAAA=='
	local logo_kmrgo_circle_micro='H4sIAEq+tFwAA5OONrA2tDY2tbY0zX00edajyXOkISKG1paGQJGFjyZPg4oYW1saA0XmAbm5XADN
MymqOAAAAA=='
	local logo_kmrgo_brailebox_small='H4sIAB+/tFwAA3s0pefRlAYS0QSuR1OaFKSjDawNrY1NrS1Ncx8tbIdyDa0tDYHcBUBuLkyJsbWl
ce6jxQ1ABBaGiZtZW5oB1cLFocIm1pYmuY8WNaBagKIEYsuiBqgw0DnIToLILuhHsX7BImQDjKwt
jYBi7UCE4hgwF80lYIMQroa4Z/FEVA/vwvTwgsWPFsxBOG8K6QE9gwsAuJNIp6ABAAA='
	local logo_Camargo_script_sign='H4sIABXAtFwAA6WSQQrDIBBF916hG5ctBLRECMGjVJgTeIM5fCdmgn5MgqUuAv/PvPjVsfbx8fEd
5xDXkIlIZLaDywDsCto6T3r98DuzoXPIXBl1iCb1DmOXRS3nqmqElzxBh2T1cfW1Dc3d66Op4WBr
BlXvYyvdqRMMYnBv/dnVvxtYqZzbHJGSzIVL5Jguz3sTgpGFjbQmHy2boVGB+M28jNPydqkFvyIs
gSUIAwAA'
	local logo_CAMARGO_future_small="H4sIAKC/tFwAA6WSPQ6CQBCFe65g4xHkN9nMUTwDdxBoTTRhNphQUlragMeZkziyI7MLsSIhITz2
vW/eAOGV8LLvukeE9eF8ghjSHExeEt4IK1FiMHFJdmRRlBRMymcqwlaUBEziXC9RCjAFK626MjBZ
6PrH8l0Ly44bVrVi8SPfaq+N5DXfN8djGDmEeTzXM8xrnNGbvVGXzO65hDXoDgTUa45j2bfu4Mea
J1zRtn0ksdPukjiSnfwIFztrmhgecQ3stJLlc08BkU9htyYuinTgXfRhA29O2VevnXD3f/uIPlzE
0Zv+AgAA"
	local logo_script_bigmono12_big='H4sIADnBtFwAA8VW2w2DMAz8zwr9YQQqIlUoo3QG9uhvgtQBO0kpT9s5m1AqFfFF7Nxd7Jypqu8f
dyK3JPlyr8M1NHVo6+71fAzv8KUzNvwkNH6ITVP48iYr7zjOCHPLYfYyVyQfWm8hrTpYBAFmshgd
G1+hpGFZh8LX+zVE6NsOH61FcHSMkEAWazSdwpAzAsVB2rI2QWxRoWFFJf8D4hTmebHl7rBYTvDL
GxZXp0eonrdYLiXSDmFEVY1AlNCypBr96CT9CI5noi/kaLzx7dQlyWaKG862FHmiLaiCbgboM4qY
oULTUKBwFM0uopCrOUpsSZopwoYu6KFCOdxoWEF4mxTJoFQS249OAvEVXSPeD/z27ZktogaNCqnl
3kRFo6uQDRvDb5KqwvRMrHbXePE1UI0tCwNNJSeC9A86Gn4w93S1liRsXSrHUSKYr+U/bcbtm5//
7VXwu3bu7/QNxobC5xgLAAA='
	local logo_script_pagga_small='H4sIAKbAtFwAA62SwQnDMAxF71mhS9RxEhAapTNkB1F68CGHCkzofJ6khgosRS0NIeDT56PHs1Ty
UjKd9J5dyffL7YoB44gwzmXlsiZJAkKoCdUnSUSIttMj9LYzIUy2MyAMn87Dsciy0j5WciyyLJkz
Vz2lKBB2EHIQ/gZhC1EdEVKKjcWWlVryk0VOSM0RlszZKLZfox0bIrch+rch/3nHWF5IJe3ylGI+
7+5f3RsPz3enRwMAAA=='

	local cols=$(tput cols)
	local message="basename $0 .sh"
	message=${1:-'kmrgo'}
	# verifica se lolcat está ativo
	[ $(command -v lolcat) ] && lolcat="lolcat" || lolcat="cat"
	# pega os comandos disponiveis
	# cowsay e banner estão  desativados por enquanto, para ativar add no vetor abaixo
	local ascii_available=( figlet toilet boxes base64DB )
	local ascii_enable=()
	for i in "${ascii_available[@]}"; do
		[ $(command -v $i) ] && ascii_enable+=( "$i" )
	done
	local count=0
	local size=$(( $(printf "%*s" "$cols" "a" | wc -c ) + 2 ))
	while [ $size -gt $cols ] && [ $count -le 5 ]; do
		ascii_activated="$(randomValue "${ascii_enable[@]}")"
		case $ascii_activated in
			"cowsay")
			local cowsay_draws=( $(cowsay -l | grep -v "files in") )
			local cowsay_options=( "-b" "-d" "-p" "-s" "-t" "-w" "-t" "-y" "" )
			local draw="$(cowsay -W $(( $cols*100 / 120 )) $(randomValue ${cowsay_options[*]}) -f "$(randomValue ${cowsay_draws[*]})" "$message" )"
			;;
			"figlet")
			local figlet_fonts=( $(ls -m --format='across' /usr/share/figlet/ | grep -v .flc) )
			local figlet_options=( '-c' '-l' '-x' )
			local draw="$(figlet $(randomValue ${figlet_options[*]}) -t -f "$(randomValue ${figlet_fonts[*]})" $message )"
			;;
			"toilet")
			local toilet_options=( '-S' '-s' '-k' '-W' '-o' )
			local toilet_color=( '--metal' '--gay' '' )
			local toilet_border=( '-F border' '' )
			local figlet_fonts=( $(ls -m --format='across' /usr/share/figlet/ | grep -v .flc) )
			local draw="$(toilet $(randomValue ${toilet_options[*]}) "$(randomValue ${toilet_color[*]})" "$(randomValue ${toilet_border[*]})" -w 10000 -f "$(randomValue ${figlet_fonts[*]})" $message )"
			;;
			"boxes")
			# ADICIONAR O figlet no input do boxes, talve o toilet tb, sem cores
			local boxes_draws=( xes whirly unicornthink unicornsay twisted sunset stone stark2 stark1 spring scroll-akn scroll santa peek parchment nuke mouse important3 important2 important ian_jones headline girl fence face  dog diamonds columns cat capgirl boy )
			if [[ "${ascii_enable[@]}" =~  "banner" ]]; then
				local draw="$(banner $message | boxes -d $(randomValue ${boxes_draws[*]}) -a c)"
			else
				local draw="$(echo $message | boxes -d $(randomValue ${boxes_draws[*]}) -a c)"
			fi
			;;
			"banner")
			local draw="$(banner $message)"
			;;
			"base64DB")
			local aux="$(randomValue ${!logo@})"
			local draw="$(base64 -d <<<${!aux}| gunzip)"
			;;
			*)
			local draw="${message^^}"
			;;
		esac
		((count++))
		size=$(echo "$draw" | head -n 1 | wc -c)
	done
	if [ ! -z "$(echo "$draw" | grep '\-\-metal\|\-\-gay')" ] || [[ "$ascii_activated" == 'base64DB' ]]; then
		lolcat="cat"
	fi
	[ $size -le $cols ] && { echo "$draw" | $lolcat; } || { echo "$message" | $lolcat; }

	# HOW TO GENERATE B64
	#IFS='' var="$(cowsay -f ghostbusters kmrgo | tail -n21)"; varzip="$(echo $var | gzip | base64)"; echo $varzip; base64 -d <<<${varzip}| gunzip # generate and echo the ascii art
	# cowsay -f ghostbusters kmrgo
	# cowsay -l to show draws
	# # Figlet: -c to align center
	# figlet -f script.flf $1
	# figlet $1 -f block
	# figlet $1 -f digital
	# figlet $1 -f mini
	# figlet $1 -f small
	# figlet $1
	# toilet -f future -F border --filter gay "Camargo"
	# figlet $1 -f smslant
	# for i in ${!logo*}; do
	# 	echo IIIIIIIIIIIIII $i
	# 	local vardraw="$(base64 -d <<<"${!i}" | gunzip)"
	# 	local size="$( echo ${vardraw} | head -n1 )"
	# 	debugCheckPoint cols vardraw size i
	# 	if [ $cols -ge ${#size} ]; then
	# 		echo "$vardraw"
	# 		continue
	# 	fi
	# done
}

# $* tagkey:tagvalue^key_value
#tagPrint 🐳build:passing:bg_grey_dark:bg_green_light 🐧linux:debian:bg_grey_dark:bg_red version:0.12:bg_yellow:bg_green 🐳build:passing
#  🐳build  passing   🐧linux  debian   version  0.12   🐳build  passing
# TODO: usar getopts e mudar outros scripts
tagPrint (){
	local key value color_key color_value
	local error_ message="Erro tagprint, argumentos: chave:valor:cor1:cor2"
	local type='_bold'
	local available_colors=( bg_black$type bg_red$type bg_green$type \
	bg_yellow$type bg_blue$type bg_magenta$type bg_cyan$type \
	bg_red_light$type bg_green_light$type bg_yellow_light$type \
	bg_blue_light$type bg_cyan_light$type )
	[ $# = 0 ] && { echo "$error_message" ; return 1; }
	echo ''
	local array_parameters=( 'key' 'value' 'color1' 'color2' ) # tem q setar manualmente pra manter a ordem
	declare -A apval=(['key']='status' ['value']='ok' ['color1']='bg_grey_dark:bg_*' ['color2']='bg_green')
	# convert associative array to string
	aux=$(declare -p apval)
	# create new associative array from string
	eval "declare -A apset="${aux#*=}
	local cols=$(tput cols)

	local size=0
	# para cada argumento passado (tag)
	for i in "$@"; do
		local sub_arguments=()
		local random_color=${available_colors[RANDOM%${#available_colors[@]}]} # Random array elements
		# separa o argumento em subargumentos
		IFS=$':' GLOBIGNORE='*' command eval 'sub_arguments=($i)';

		# RESET apset
		for i in "${array_parameters[@]}"; do
			apset[$i]=''
		done

		local count=0
		# para cada divisao do argumento passado tab:valor:cor1:cor2, tag valor cor1 e cor2
		for j in "${array_parameters[@]}"; do
			local argument_passed="${sub_arguments[$count]}"
			# divide o cada elemento do vetor que verifica os argumentos, em subargumentos
			IFS=$':' GLOBIGNORE='*' command eval 'param_value_condition=(${apval[$j]})'; # coloca varios elementos em um vetor rapidamente, seguindo um padrao
			# se a subdivisao está de acordo, entao o valor é o de j, senao é o valor padrao
			# O array de divisao deve ser no formato [key]='valor:condicao'
			if printf "$argument_passed\n" | grep -Eq "${param_value_condition[1]}"; then
				apset["$j"]=$argument_passed
			else
				apset["$j"]=${param_value_condition[0]}
			fi
			((count++))
		done

		# Set default values for apset if not set
		for i in "${array_parameters[@]}"; do
			if [ ! "${apset[$i]}" ]; then
				apset[$i]=${param_value_condition[0]}
			fi
		done

		tag=${!apset['color1']}" "${apset['key']}" "${!apset['color2']}" "${apset['value']}" "${def}

		size=$(( $size + ${#tag} ))
		if [ $(( $size/$cols )) -gt 1 ]; then
			line_break="\n"
			size=${#tag}
		else
			line_break=''
		fi
		# ADICIONAR um verificador de fim de linha para saber se imprime nesta ou adicionar um \n ante, para nao quebrar as tags
		echo -en "$tag $line_break"
	done
	echo ''
}
centerPrint () 
{ 
    local color1=${3:-'white_bold'};
    local color2=${4:-'white_bold'};
    local text=${1:-"STEP"};
    local char=${2:-"."};
    width=$(tput cols);
    width_sides=$(( ( $width - ${#text} )/2 - 1));
    printf -v side "%*s" "$(( $width_sides/${#char} ))" "";
    side=${side// /"$char"};
    printf "%b %b %b
" "${!color1}$side$def" "${!color2}${text}$def" "${!color1}$side$def"
}

debugCheckPoint () 
{ 
    pauseEnable="no";
    echo -ne "$cyan_bold > Line Nº: $LINENO$def";
    echo -e "$cyan_bold	> Script: $white_bold $(basename $0)$def";
    echo -e "$cyan_bold > Actual folder: $white_bold $PWD$def";
    if [ "$1" = '-p' ]; then
        pauseEnable="yes";
        shift 1;
    fi;
    if [ "$1" ]; then
        for iz in "$@";
        do
            if [ ! "$(varType $iz)" = 'array' ]; then
                echo -e "$green_bold Variable $iz:$white_bold ${!iz}$def";
            else
                narrayelms=`eval 'echo -e "${#'$iz'[@]}"'`;
                if [ $narrayelms -gt 1 ]; then
                    eval 'echo -e " [01;32m'$iz'[01;00m: ARRAY with ${#'$iz'[@]} elements, FROM "${'$iz'[0]}" TO "${'$iz'[-1]}" - elements not checked[0;00m"';
                else
                    eval 'echo -e " [01;33m'$iz'[01;00m: ARRAY with ${#'$iz'[@]} elements"';
                fi;
            fi;
        done;
        if [ "$pauseEnable" = 'yes' ]; then
            read -p "$(echo -e "$yellow_bold>> Enter to continue "$def)" temp;
        fi;
    else
        variables_after="$(compgen -v)";
        variables_declared=($(diff <(echo "$variables_before") <(echo "$variables_after") | grep '>' | grep -Ev 'PIPESTATUS|variables_before|FUNCNAME|[> ][_]' | cut -d ' ' -f2-));
        for iz in ${variables_declared[@]};
        do
            echo -e "$green_bold > Variable: $iz $yellow_bold ${!iz} $def";
        done;
    fi
}
exitError () 
{ 
    local message=${1:-'Tarefa'};
    [ -f /usr/games/cowsay ] && cowsay -f "$(ls /usr/share/cowsay/cows | shuf -n 1 | cut -d. -f1)" "$message" | { 
        [ -f /usr/games/lolcat ] && lolcat -S 100 -a -d 1 || cat
    };
    printMessage -f "$message executado(a) com ERRO FATAL";
    [ "$2" ] && eval "$2";
    exit 1
}
printHeader () 
{ 
    function smallHeader () 
    { 
        tag_print='version:'${help_version:="1.0"}':bg_grey_dark:bg_green 📜license:'${help_license:="MIT"}':bg_grey_dark:bg_blue';
        playsnd='no';
        size='-s'
    };
    function bigHeader () 
    { 
        tag_print="☃linux:debian:bg_grey_dark:bg_red ☕version:'${help_version:="0.1"}':bg_grey_dark:bg_green ♖license:'${help_license:="MIT"}':bg_grey_dark:bg_blue status:☢_alpha:bg_grey_dark:bg_yellow";
        size='-b';
        local playsnd='yes'
    };
    function completeHeader () 
    { 
        echo "Complete Header"
    };
    variables_after="$(compgen -v)";
    variables_declared=($(diff <(echo "$variables_before") <(echo "$variables_after") | grep '>' | grep -Ev 'PIPESTATUS|variables_before|FUNCNAME|[> ][_]|help_.*' | cut -d ' ' -f2-));
    local script_name="$(echo "$(basename "$0" .sh)" | tr '[:upper:]' '[:lower:]' | sed -E "s/[_]/ /g;s/  */ /g;s/^./\u&/;s/(\s)(\w+)/\1\u\2/g")";
    local playsnd='no';
    local size='-s';
    local tag_print='☕version:'${help_version:="0.1"}':bg_grey_dark:bg_green ✌license:'${help_license:="MIT"}':bg_grey_dark:bg_blue';
    quietArg='';
    local args=();
    while [ $# -gt 0 ]; do
        case "$1" in 
            -s | --small)
                smallHeader;
                shift 1
            ;;
            -b | --big)
                bigHeader;
                shift 1
            ;;
            -c | --complete)
                completeHeader;
                shift 1
            ;;
            -q | --quiet)
                quiet="true";
                quietArg="-q";
                shift 1
            ;;
            *)
                local args+=("$1");
                shift
            ;;
        esac;
    done;
    if [ "$(runningStatus)" == "gui" ]; then
        [ "$quiet" == "true" ] && timeout="-timeout 10";
        text='<span color=\"green\" font="Verdana 20" >'$script_name'
</span> \
		<span color=\"blue\" font="12" >
</span> \
		<span color=\"blue\" font="12" >
</span> \
		<span color=\"blue\" font="12" >
 </span> \
		<span color=\"yellow\" font="12" >

Deseja Prosseguir?</span>';
        text="`eval 'echo "<span color=\\"green\" font=\\"Verdana 20\\" >'$script_name'

</span><span color=\\"blue\" font=\\"Verdana 14\\" >Description: '${help_description:="See help for more info."}'
Author: '${help_author:="Otavio Camargo kmrgo kmrgo at outlook dot com."}'
Contact: '${help_contacts:="http://kmrg.o.gp"}'
</span>"'`";
        [ "$quiet" == "true" ] && quiet="-q";
        [ ! -z $variables_before ] && checkVariables "$quietArg" "${variables_declared[@]}";
        yad --width 500 --height 300 --title "`basename "$0"`" --button=gtk-cancel:1 --button=gtk-help:2 $timeout --button=gtk-execute:0 --buttons-layout=center --image /home/$USER/bin/kmrgo_logo.png --text="$text";
        case $? in 
            1 | 252)
                exit 1
            ;;
            2)
                printHelp -i
            ;;
        esac;
    else
        [ "$size" = "-b" ] && printLogo ${args[0]:-$script_name} || toilet -F metal -f future -F border ${args[0]:-$script_name} | lolcat --seed 09;
        [ "$playsnd" = "yes" ] && playBashSound;
        tagPrint ${tag_print};
        echo -e "$white_bold Description: ${help_description:="See help (-H) for more info and -M for full manual"}$def";
        echo -e "$white_bold Author: ${help_author:="Otávio Augusto @oaugustopro <contact@oaugusto.pro>"}$def";
        echo -e "$white_bold Contact: ${help_contacts:="http://oaugusto.pro"} $def";
        [ "$quiet" == "true" ] && quiet="-q";
        [ ! -z "$variables_before" ] && checkVariables $quiet "${variables_declared[@]}";
        centerPrint "$script_name execution" '=' 'white_def';
    fi
}
printHelp () 
{ 
    function printScriptMan () 
    { 
        local var='';
        full_header=();
        stop_loop='no';
        while IFS= read -r var && [ ! $stop_loop = 'yes' ]; do
            if [ "$(echo "$var" | grep -E ^\#)" ]; then
                if [ ! "$(echo "$var" | grep '#!/bin/bash' )" ]; then
                    full_header+=("$var
");
                else
                    continue;
                fi;
            else
                stop_loop='yes';
            fi;
        done < "$0";
        groff -man -E -Tascii -c < <(printf '%s
' "${full_header[@]}" | sed 's/# //g') 2> /dev/null
    };
    function printMan () 
    { 
        new_help_synopsis="$(echo [-${help_synopsis//:/ arg, -} | sed "s/--long /[--/g")]";
        full_text='';
        for i in ".TH "$(basename $0 .sh | tr [:lower:] [:upper:] )" 1 \"`date +"%Y-%m-%d"`\" \"version ${help_version:="1.0"}\" \"User Manuals\"" ".SH NAME" "$(basename $0 .sh | tr [:upper:] [:lower:] ) \- ${help_short_description:="do what is expected"}." ".SH SYNOPSIS" ".BR $(basename $0)  " ".I args" ".B ${new_help_synopsis}" ".SH DESCRIPTION" ".B $(basename $0)" "${help_short_description:="Do what is expected"}. ${help_long_description:="Look into repository for more info"}" ".SH OPTIONS" "${help_options[@]/#/".IP "}" ".SH FILES" ".I /home/$USER/bin/libkrmgobash.sh" ".RS" "The main library to make everything works." "${help_files[@]}" ".SH DEPENDENCIES" ".B iptables ${help_dependencies[@]}" ".SH BUGS" "${help_bugs:="No known bugs."}" ".SH NOTES" "${help_notes:="See the repository in http://github.com/oaugustopro"}" ".SH EXAMPLE" "${help_examples[@]/#/".B "}" ".SH AUTHORS" "${help_authors:="Otavio Augusto (@oaugustopro) < contact at oaugusto dot pro>"}" ".P" "${help_contacts:="Website https://oaugusto.pro"}" ".SH LICENSE" "${help_license:="MIT, `date +"%Y"`"}" ".SH SEE ALSO" ".BR ${help_see_also:="bash(1)"}";
        do
            full_text+="$i
";
        done;
        printMessage -i "`groff -E -man -Tascii < <(echo -e "$full_text")`"
    };
    function printInfo () 
    { 
        full_text='';
        for i in "Name: `basename "$0"` 	 Version: ${help_version:="1.0"}" "Description: ${help_short_description:="No description provided."}" "Options:
${help_options[@]}" "Examples:
${help_examples[@]}" "Author: ${help_authors:="Otavio Augusto Maciel Camargo (kmrgo) kmrgo at outlook dot com"}" "License: ${help_license:="MIT, `date +"%Y"`"}" "Depends on: ${help_dependencies}" "Notes: ${help_notes:="See the repository in http://gitlab.com/kmrgo"}";
        do
            full_text+="`echo -e "$i" | sed -E "s/^\.{1}[A-Z]+[ ]+//g"`
";
        done;
        printMessage -i "$full_text"
    };
    function printAllExceptExamples () 
    { 
        full_text='';
        for i in "Name: `basename "$0"` 	 Version: ${help_version:="1.0"}" "Description: ${help_short_description:="No description provided."}" "Options:
${help_options[@]}" "Author: ${help_authors:="Otavio Augusto Maciel Camargo (kmrgo) kmrgo at outlook dot com"}" "License: ${help_license:="MIT, `date +"%Y"`"}" "Depends on: ${help_dependencies}" "Notes: ${help_notes:="See the repository in http://gitlab.com/kmrgo"}";
        do
            full_text+="`echo -e "$i" | sed -E "s/^\.{1}[A-Z]+[ ]+//g"`
";
        done;
        printMessage -i "$full_text"
    };
    centerPrint "Help" " .. " cyan;
    local theargs=();
    while [ $# -ge 0 ]; do
        case "$1" in 
            -m | --man)
                shift;
                printMan;
                return 0
            ;;
            -i | --info | -h | --help)
                shift;
                printInfo;
                return 0
            ;;
            *)
                shift;
                printAllExceptExamples;
                return 0
            ;;
        esac;
    done
}
printMessage () 
{ 
    while [ $# -gt 0 ]; do
        case $1 in 
            -a | -w | --warning | --alert | --alerta)
                shift 1;
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                case $(runningStatus) in 
                    gui)
                        case $(uname -s) in 
                            Android)
                                termux-toast "$message"
                            ;;
                            *)
                                yad --image=dialog-question --text="$message" || zenity --warning --text "$message" || xmessage -print "$message" || xterm -hold -fa monaco -fs 16 -geometry 50x10 -bg black -e echo -e "[1;33m"'/!\/!\/!\/!\ '"[1;31m${message}[1;33m"' /!\/!\/!\/!\ [0;00m' || return 1
                            ;;
                        esac;
                        return 0
                    ;;
                    *)
                        centerPrint "$message" ' !' yellow_bold red_bold;
                        return 0
                    ;;
                esac
            ;;
            -f | -fatal | -e | --error)
                shift 1;
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                case $(runningStatus) in 
                    gui)
                        case $(uname -s) in 
                            Android)
                                termux-toast "$message"
                            ;;
                            *)
                                yad --image=dialog-question --text="$message" || zenity --info --title="Info" --text=" $message" --width="100" height="50" || xmessage -print "$message" || xterm -hold -fa monaco -fs 16 -geometry 50x10 -bg black -e echo -e "[1;33m"'oOoOoOoOo '"[1;31m${message}[1;33m"'  oOoOoOoOo[0;00m' || return 1
                            ;;
                        esac;
                        return 0
                    ;;
                    *)
                        centerPrint "$message" '<!>' red_bold yellow_bold;
                        return 0
                    ;;
                esac
            ;;
            -g | --good | --fine | -b | --bom | --sucesso | --sucess)
                shift 1;
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                case $(runningStatus) in 
                    gui)
                        case $(uname -s) in 
                            Android)
                                termux-toast "$message"
                            ;;
                            *)
                                yad --image=dialog-question --text="$message" || zenity --info --title="Info" --text=" $message" --width="100" height="50" || xmessage "$message" || xterm -hold -fa monaco -fs 16 -geometry 50x10 -bg black -e echo -e "[1;33m"'oOoOoOoOo '"[1;31m${message}[1;33m"'  oOoOoOoOo[0;00m' || return 1
                            ;;
                        esac;
                        return 0
                    ;;
                    *)
                        case $osName in 
                            Android)
                                termux-toast "$message"
                            ;;
                            Linux)
                                centerPrint "$message" ' _ ' green_bold white_bold
                            ;;
                        esac;
                        return 0
                    ;;
                esac
            ;;
            -n | --notification)
                shift 1;
                case $(uname -s) in 
                    Android)
                        termux-toast "$message"
                    ;;
                    *)
                        message="$(echo "${@}" | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                        notify-send -i info "Notificação" "$message"
                    ;;
                esac;
                return 0;
                return 0
            ;;
            -t | --timeout)
                shift 1;
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                case $(runningStatus) in 
                    gui)
                        zenity --info --title="Info" --timeout=2 --text=" $message" --width="100" height="50";
                        return 0
                    ;;
                    *)
                        centerPrint "$message" ' _ ' green_bold white_bold;
                        return 0
                    ;;
                esac
            ;;
            -i | --info)
                shift 1;
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g;s/[<>]//g")";
                case $(runningStatus) in 
                    gui)
                        if command -v yad &> /dev/null; then
                            yad --width 600 --center --width 600 --height 400 --image=dialog-question --button=gtk-ok:0 --wrap --text-info < <(echo -e "$message");
                        else
                            if command -v zenity &> /dev/null; then
                                zenity --info --title="Info" --text=" $message" --width="100" height="50";
                            else
                                if command -v gxmessage &> /dev/null; then
                                    gxmessage "$message";
                                else
                                    if command -v xmessage &> /dev/null; then
                                        xmessage "$message";
                                    else
                                        if command -v xterm &> /dev/null; then
                                            xterm -hold -fa monaco -fs 16 -geometry 50x10 -bg black -e echo -e "$message";
                                        else
                                            if command -v kdialog &> /dev/null; then
                                                echo "Not implemented";
                                            else
                                                if command -v xdialog &> /dev/null; then
                                                    echo "Not implemented";
                                                else
                                                    if command -v gtkdialog &> /dev/null; then
                                                        echo "Not implemented";
                                                    else
                                                        if command -v pydialog &> /dev/null; then
                                                            echo "Not implemented";
                                                        else
                                                            if command -v cocoadialog &> /dev/null; then
                                                                echo "Not implemented";
                                                            else
                                                                echo "Error, no X app found for dialog.";
                                                                return 1;
                                                            fi;
                                                        fi;
                                                    fi;
                                                fi;
                                            fi;
                                        fi;
                                    fi;
                                fi;
                            fi;
                        fi;
                        return 0
                    ;;
                    *)
                        echo -e "$@";
                        return 0
                    ;;
                esac
            ;;
            *)
                message="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                case $(runningStatus) in 
                    gui)
                        case $(uname -s) in 
                            Android)
                                termux-toast "$message"
                            ;;
                            *)
                                yad --image=dialog-question --timeout 5 --text="$message" &
                            ;;
                        esac;
                        return 0
                    ;;
                    *)
                        centerPrint "$message" ' _ ' green_bold white_bold;
                        return 0
                    ;;
                esac
            ;;
        esac;
    done
}
printQuestion () 
{ 
    local running_status="$(runningStatus)";
    local color1=${2:-white_bold};
    local color2=${3:-cyan_bold};
    local answer='';
    local opcao='';
    function generateMenu () 
    { 
        local count=1;
        local options=();
        local gen_option;
        local args=();
        while [ $# -gt 0 ]; do
            case "$1" in 
                -c | --command)
                    readarray aux < <(eval "$2");
                    args+=("${aux[@]}");
                    shift 2
                ;;
                *)
                    local args+=("$1");
                    shift
                ;;
            esac;
        done;
        for gen_option in "${args[@]}";
        do
            if [ "$running_status" = 'gui' ]; then
                options+=("$count" "$gen_option");
            else
                options+=("$gen_option");
            fi;
            ((count++));
        done;
        if [ "$running_status" = 'gui' ]; then
            if command -v yad &> /dev/null; then
                option="$(yad --center --width 300 --height 300 --title Apps --text 'Select app:' --list --button=gtk-cancel:1 --button=gtk-ok:0 --column id --column Name "${options[@]}" | cut -d '|' -f2 )";
                [ "$option" != '' ] && echo $option || return 1;
            else
                if command -v zenity &> /dev/null; then
                    option="$(zenity --info --title="Questão" --text=" $@" --entry)";
                    [ "$option" != '' ] && echo $option || return 1;
                else
                    if command -v gxmessage &> /dev/null; then
                        option="$(gxmessage -entry "$@")";
                        [ "$option" != '' ] && echo $option || return 1;
                    else
                        xmessage -timeout 10 "Erro!";
                        return 1;
                    fi;
                fi;
            fi;
        else
            case "$(uname -s)" in 
                'Android')
                    oldIFS=$IFS;
                    IFS=',';
                    argsArray=$(echo "$*");
                    IFS=$oldIFS;
                    option=$(termux-dialog radio -t "Questão" -v "$argsArray" | jq .text -r );
                    [ "$option" != '' ] && echo $option || return 1
                ;;
                'Linux')
                    read -p "$(count=1;				for gen_option in "${args[@]}"; do 				printf '%b %s %b
' "$green_bold[$def $count$green_bold]$def" "-" "${gen_option%[	
]*}";				((count++));				done;				echo '>') Digite a opção desejada: " option;
                    [ "$option" != '' ] && option="${options[$(( $option - 1 ))]%[	
]*}" && echo "$option" || return 0
                ;;
            esac;
        fi;
        return 0
    };
    function readValue () 
    { 
        local color1=${2:-white_bold};
        local message="${1:-"Digite: "}";
        local answer='';
        case $(runningStatus) in 
            gui)
                themessage="$(echo "$@" | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                if command -v yad &> /dev/null; then
                    answer="$(yad --title "Questão" --window-icon=gtk-yes --timeout=1000 --text-align=center --sticky --on-top --center --text="$themessage" --entry)";
                else
                    if command -v zenity &> /dev/null; then
                        answer="$(zenity --info --title="Questão" --text=" $themessage" --entry)";
                    else
                        if command -v gxmessage &> /dev/null; then
                            answer="$(gxmessage -entry " $themessage ")";
                        else
                            return 1;
                        fi;
                    fi;
                fi
            ;;
            *)
                case "$(uname -s)" in 
                    Android)
                        answer=$(termux-dialog text -i "$message" -t "Inserir valor" |  jq .text -r)
                    ;;
                    Linux)
                        read -p "$(echo -e ${!color1} $message: $def )" answer
                    ;;
                esac
            ;;
        esac;
        echo "$answer";
        [ "$answer" == '' ] && return 1;
        return 0
    };
    function yesNo () 
    { 
        local yes=(Sim SiM SIm SIM sim sIm siM sIM s S Yes YeS YEs YES yes yEs yES yeS y Y);
        local color1=${2:-white_bold};
        local color2=${3:-cyan_bold};
        local message="${1:-"Continuar? "}";
        case $(runningStatus) in 
            gui)
                themessage="$(echo "$@" | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                if command -v yad &> /dev/null; then
                    yad --title "Questão" --window-icon=gtk-yes --timeout=1000 --text-align=center --sticky --on-top --center --text="$themessage";
                    return $?;
                else
                    if command -v zenity &> /dev/null; then
                        zenity --info --title="Questão" --text=" $themessage" --question;
                        return $?;
                    else
                        if command -v xmessage &> /dev/null; then
                            xmessage "$themessage" -center -buttons yes,no;
                            return $(( $? - 101 ));
                        else
                            return 1;
                        fi;
                    fi;
                fi
            ;;
            *)
                case "$(uname -s)" in 
                    'Android')
                        answer=$(termux-dialog confirm -i "$themessage" -t "Confirmar" | jq .text -r )
                    ;;
                    'Linux')
                        read -p "$(echo -e "${!color1}""$message"" ${!color2} [s/N]: $def ")" answer
                    ;;
                esac;
                [[ " ${yes[@]} " =~ " $answer " ]] && return 0 || return 1
            ;;
        esac
    };
    function proceed () 
    { 
        local yes=(Sim SiM SIm SIM sim sIm siM sIM s S Yes YeS YEs YES yes yEs yES yeS y Y);
        local color1=${2:-white_bold};
        local color2=${3:-cyan_bold};
        local message="${1:-"Continuar? "}";
        case $(runningStatus) in 
            gui)
                themessage="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                if command -v yad &> /dev/null; then
                    yad --title "Questão" --window-icon=gtk-yes --width 500 --height 300 --timeout=1000 --text-align=left --sticky --on-top --center --wrap --text-info < <(echo -e "$themessage");
                    [ $? != 0 ] && exit 1;
                    return $?;
                else
                    if command -v zenity &> /dev/null; then
                        zenity --info --title="Questão" --text=" $themessage" --question;
                        [ $? == 1 ] || [ $? == 252 ] && exit 1;
                        return $?;
                    else
                        if command -v xmessage &> /dev/null; then
                            xmessage "$themessage" -center -buttons yes,no;
                            [ $? == 1 ] || [ $? == 252 ] && exit 1;
                            return $(( $? - 101 ));
                        else
                            return 1;
                        fi;
                    fi;
                fi
            ;;
            *)
                case "$(uname -s)" in 
                    'Android')
                        answer=$(termux-dialog confirm -i "$themessage" -t "Confirmar" | jq .text -r )
                    ;;
                    'Linux')
                        read -p "$(echo -e "${!color1}""$message"" ${!color2} [s/N]: $def ")" answer
                    ;;
                esac;
                if echo "${yes[@]}" | grep -q "$answer" && [ ! -z "$answer" ]; then
                    return 0;
                else
                    exit 1;
                fi
            ;;
        esac
    };
    function noYes () 
    { 
        local no=(Não Não Nao NaO NÃo NAo NAO NÃO não nao nÃo nAo nãO naO nÃO nAO n N No NO no nO not NOT Not);
        local color1=${2:-white_bold};
        local color2=${3:-cyan_bold};
        local message="${1:-"Parar? "}";
        case $(runningStatus) in 
            gui)
                themessage="$(echo $@ | sed -E "s/[\]{1}033\[[0-5]+;[0-9]{1,2}m//g")";
                if command -v yad &> /dev/null; then
                    yad --title "Questão" --window-icon=gtk-yes --timeout=1000 --text-align=center --sticky --on-top --center --text="$themessage";
                    return $?;
                else
                    if command -v zenity &> /dev/null; then
                        zenity --info --title="Questão" --text=" $themessage" --question;
                        return $?;
                    else
                        if command -v xmessage &> /dev/null; then
                            xmessage "$themessage" -center -buttons yes,no;
                            return $(( $? - 101 ));
                        else
                            return 1;
                        fi;
                    fi;
                fi
            ;;
            *)
                case "$(uname -s)" in 
                    'Android')
                        answer=$(termux-dialog confirm -i "$themessage" -t "Confirmar" | jq .text -r )
                    ;;
                    'Linux')
                        read -p "$(echo -e "${!color1}"$message" ${!color2}[S/n]: $def ")" answer
                    ;;
                esac;
                [[ " ${no[@]} " =~ " $answer " ]] && return 1 || return 0
            ;;
        esac
    };
    local args=();
    while [ $# -gt 0 ]; do
        case "$1" in 
            -y | --yesno)
                shift 1;
                yesNo "${args[@]}" "$@";
                return $?
            ;;
            -n | --noyes)
                shift 1;
                noYes "${args[@]}" "$@";
                return $?
            ;;
            -r | --readvalue)
                shift 1;
                readValue "${args[@]}" "$@";
                return $?
            ;;
            -p | --proceed)
                shift 1;
                proceed "${args[@]}" "$@";
                [ $? -eq 1 ] && exit 1;
                return $?
            ;;
            -m | --menu)
                shift 1;
                generateMenu "${args[@]}" "$@";
                return $?
            ;;
            *)
                local args+=("$1");
                shift
            ;;
        esac;
    done
}
spacedPrint () 
{ 
    local color1="${4:-white_bold}";
    local color3="${5:-white}";
    local color2="${6:-$(setColorByWord $2)}";
    local text1="${1:-"Checking"}";
    local text3="${3:-"."}";
    if [[ ! "$@" =~ [-]+[Nn]+o[-_+]*[Ss]+ign$ ]]; then
        local text2="$( [ ! "$2" ] && genSign 'OK' || genSign "$2" )";
        text2="$(genSign "$2")";
    else
        local text2="${2:-'ok'}";
    fi;
    w=$(( $(tput cols) - ${#text1} - ${#text2} - 2));
    if [ "${#text3}" -gt 3 ]; then
        w=$(( $(tput cols) - ${#text1} - 4 ));
        dots="$text3";
        if [[ "$@" =~ [-]+[Rr]+epeat[s]*$ ]]; then
            printf "
%-${#text1}b %-${w}b %${#text2}b" "${!color1}$text1$def" "${!color3}${dots}$def" "${!color2}$text2$def";
        else
            printf "%-${#text1}b %-${w}b %${#text2}b
" "${!color1}$text1$def" "${!color3}${dots}$def" "${!color2}$text2$def
";
        fi;
    else
        printf -v dots "%*s" "$(( $w/${#text3} ))" "";
        dots=${dots// /"$text3"}${text3:0:$(( $w%${#text3} ))};
        printf "$rpt_beg%b %b %b$rpt_end" "${!color1}$text1$def" "${!color3}${dots}$def" "${!color2}$text2$def
";
    fi
}