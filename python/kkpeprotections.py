#!/usr/bin/python3

import pefile
import sys

def check_protections(pe):
    # Checking for Rebase (IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE)
    is_aslr = bool(pe.OPTIONAL_HEADER.DllCharacteristics & 0x0040)
    
    # Checking for SafeSEH
    has_safe_seh = False
    if hasattr(pe, 'DIRECTORY_ENTRY_LOAD_CONFIG'):
        has_safe_seh = hasattr(pe.DIRECTORY_ENTRY_LOAD_CONFIG.struct, 'SEHandlerTable') and \
                       hasattr(pe.DIRECTORY_ENTRY_LOAD_CONFIG.struct, 'SEHandlerCount')

    # Checking for NXCompat (IMAGE_DLLCHARACTERISTICS_NX_COMPAT)
    is_nxcompat = bool(pe.OPTIONAL_HEADER.DllCharacteristics & 0x0100)

    # Checking for OS DLL
    is_os_dll = bool(pe.OPTIONAL_HEADER.DllCharacteristics & 0x2000)
    
    # CFG (Control Flow Guard)
    is_cfg = False
    if (hasattr(pe, 'DIRECTORY_ENTRY_LOAD_CONFIG') and 
        hasattr(pe.DIRECTORY_ENTRY_LOAD_CONFIG, 'struct') and
        hasattr(pe.DIRECTORY_ENTRY_LOAD_CONFIG.struct, 'GuardCFCheckFunctionPointer')):
        is_cfg = True

    # Print results
    print(f"ASLR: {'Yes' if is_aslr else 'No'}")
    print(f"SafeSEH: {'Yes' if has_safe_seh else 'No'}")
    print(f"CFG: {'Yes' if is_cfg else 'No'}")
    print(f"NXCompat_(DEP): {'Yes' if is_nxcompat else 'No'}")
    print(f"OS_DLL: {'Yes' if is_os_dll else 'No'}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_pe_file>")
        return

    pe_file = sys.argv[1]

    # Load PE file
    pe = pefile.PE(pe_file)

    # Check and display protections
    check_protections(pe)

if __name__ == '__main__':
    main()
