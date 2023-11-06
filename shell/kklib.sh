#!/bin/bash

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
