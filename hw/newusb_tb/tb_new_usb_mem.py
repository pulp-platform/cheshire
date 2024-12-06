# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
# 
# Fabian Hauser <fhauser@student.ethz.ch>
# 
# Create ED and TD lists for testbench memory new_usb_tb.mem

import re

def process_file(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()

        memory_entries = {}
        max_address = 0
        end_address = None

        for line in lines:
            line = line.strip()
            if line.startswith('@'):
                parts = line.split()
                address = parts[0][3:]  # Remove '@'

                if len(address) > 16:
                    raise ValueError(f"Address exceeds 64 bits: {address}")
                if not re.fullmatch(r'[0-9A-Fa-f]+', address):
                    raise ValueError(f"Invalid address format: {address}")

                words = parts[1:]  # Extract words (32 bits each)
                if len(words) not in [4, 8]:
                    raise ValueError(f"Invalid memory entry length: {len(words)} words (must be 4 or 8)")

                # Convert words into byte list
                bytes_list = []
                for word in words:
                    if not re.fullmatch(r'[0-9A-Fa-f]{8}', word):
                        raise ValueError(f"Invalid word format: {word}")
                    bytes_list.extend([word[i:i+2] for i in range(0, 8, 2)])  # Split into 4 bytes

                # Calculate the start and end addresses
                start_address = int(address, 16)
                entry_length = len(words) * 4  # Each word has 4 bytes
                end_of_entry = start_address + entry_length

                # Check for overlapping memory addresses
                for addr in range(start_address, end_of_entry):
                    if addr in memory_entries:
                        raise ValueError(f"Memory overlap detected at address {hex(addr)}")

                # Store bytes in the memory map
                for offset, byte in enumerate(bytes_list):
                    memory_entries[start_address + offset] = byte.upper()

                max_address = max(max_address, end_of_entry)  # Track the highest address used

            elif line.startswith('END @'):
                end_address = int(line.split()[1][3:], 16)  # Extract and convert END address

        if end_address is None:
            raise ValueError("No END address specified.")

        # Ensure max_address doesn't exceed end_address
        if max_address > end_address:
            raise ValueError(f"Data exceeds END address: {hex(end_address)}")

        # Write the memory map to the output file
        with open(output_file, 'w') as f:
            addr = 0
            while addr <= end_address-1:
                line_bytes = []
                for _ in range(16):  # Each line is 16 bytes
                    line_bytes.append(memory_entries.get(addr, '00'))
                    addr += 1
                f.write(' '.join(line_bytes) + '\n')

        print(f"Memory file '{output_file}' created successfully.")

    except ValueError as e:
        print(f"Error: {e}")
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"Unexpected error: {e}")

# Example usage:
process_file('new_usb_tb_addr_mem.txt', 'new_usb_tb_mem.mem')


