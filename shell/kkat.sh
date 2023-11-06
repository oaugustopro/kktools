#!/bin/bash

source libkmrgobash.sh || { echo "Error while loading source files"; exit 1; }

echo "Uso: kkat.sh
Selecione o arquivo do diretório para ler:"

#!/bin/bash

# Check if batcat is installed
if ! command -v batcat &> /dev/null; then
    echo "'batcat' is not installed. Please install it first."
    exit 1
fi

# ANSI escape code for red text
RED='\033[0;31m'
# ANSI escape code to reset the color
RESET='\033[0m'

# Find all readable files in the current directory
readable_files=()
display_files=()
for file in *; do
    if [ -f "$file" ] && [ -r "$file" ]; then
        readable_files+=("$file")
        # Check if the file has .nmap extension and color it red
        if [[ $file == *.nmap ]]; then
            display_files+=("$(echo -e ${RED}$file${RESET})")
        else
            display_files+=("$file")
        fi
    fi
done

# Check if there are any readable files
if [ ${#readable_files[@]} -eq 0 ]; then
    echo "No readable files found."
    exit 1
fi

# Use select to let the user choose a file
PS3="Please select a file to view: "
select choice in "${display_files[@]}"; do
    # Extract the filename without color codes for reading
    file="${readable_files[$REPLY-1]}"
    if [ -n "$file" ]; then
        batcat "$file"
    else
        echo "Invalid selection."
    fi
    break
done
