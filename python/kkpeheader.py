#!/usr/bin/python3

import pefile
import sys

# Define flags
FLAGS = {
    "IMAGE_SCN_MEM_EXECUTE": 0x20000000,  # Executable as code
    "IMAGE_SCN_MEM_READ": 0x40000000,     # Readable
    "IMAGE_SCN_MEM_WRITE": 0x80000000,    # Writeable
    "IMAGE_SCN_CNT_CODE": 0x00000020,     # Contains executable data
    "IMAGE_SCN_CNT_INITIALIZED_DATA": 0x00000040,  # Contains initialized data
    "IMAGE_SCN_CNT_UNINITIALIZED_DATA": 0x00000080  # Contains uninitialized data
}

def display_section_flags(pe, section_name):
    for section in pe.sections:
        if section.Name.decode('utf-8').rstrip('\x00') == section_name:
            print(f"Flags for section {section_name}:")
            for flag_name, flag_value in FLAGS.items():
                is_set = "Set" if section.Characteristics & flag_value else "Not Set"
                print(f"  {flag_name}: {is_set}")
            return
    print(f"Section {section_name} not found!")

def set_section_flags(pe, section_name):
    # Combine flags
    new_flags = sum(FLAGS.values())

    # Look for the section and modify its flags
    for section in pe.sections:
        if section.Name.decode('utf-8').rstrip('\x00') == section_name:
            section.Characteristics = new_flags

def main():
    if len(sys.argv) != 3:
        print("Usage: python script_name.py <path_to_pe_file> <section_name>")
        return

    pe_file = sys.argv[1]
    section_name = sys.argv[2]

    # Load PE file
    pe = pefile.PE(pe_file)

    # Display section flags before modification
    print("Before modification:")
    display_section_flags(pe, section_name)

    # Modify section flags
    set_section_flags(pe, section_name)

    # Display section flags after modification
    print("\nAfter modification:")
    display_section_flags(pe, section_name)

    # Save the modified PE file
    output_file = 'modified_' + pe_file.split('/')[-1]
    pe.write(filename=output_file)
    print(f"\nModified binary saved as: {output_file}")

if __name__ == '__main__':
    main()

