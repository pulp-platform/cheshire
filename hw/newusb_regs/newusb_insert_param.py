# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
# 
# Fabian Hauser <fhauser@student.ethz.ch>
# 
# The regtool only supports parameters in some cases.
# Via this script newusb_reg_template.hjson gets filled with the literal parameter values from new_usb_ohci_pkg
# and newusb_reg.hjson is generated from it to bypass the parameter incompatability. Additionally a few things
# have different write/read protections depending on the USB setup inside new_usb_ohci_pkg.
# Always make changes in the template never in the newusb_regs.hjson.

import re
import shutil 

#Extract parameters

macro_mapping = {
    "OFF": 0,
    "GLOBAL": 1,
    "INDIVIDUAL": 2,
    "DISABLE": 0,
    "ENABLE": 1,
}

def replace_macros(localparams):
    # Replace macros in each value with their constant definitions
    return [(var, macro_mapping.get(value, value)) for var, value in localparams]

def extract_localparams(filename):
    # List to store extracted data
    localparams = []

    # Flags for tracking "package ...;" and "endpackage" block
    inside_package = False

    with open(filename, 'r') as file:
        for line in file:
            # Detect the start and end of the package block
            if re.search(r"^package\b", line):
                inside_package = True
                continue
            elif re.search(r"^endpackage\b", line):
                inside_package = False
                continue
            
            # Process lines starting with 'localparam' within the package block
            if inside_package and line.strip().startswith("localparam"):
                # Updated regex to capture the format: localparam <type> <VariableName> = <Value>;
                match = re.search(r"localparam\s+\w+(\s+\w+)?\s+([A-Z]\w*)\s*=\s*([\w\d_]+);", line)
                
                if match:
                    # Extract the variable name and value
                    variable_name = match.group(2)  # The capitalized variable name
                    variable_value = match.group(3) # The value or macro after '='
                    
                    # Store the localparams in a list
                    localparams.append((variable_name, variable_value))

    return localparams

localparams = extract_localparams("hw/newusb/new_usb_ohci.sv")
localparams_without_macros = replace_macros(localparams)

'''
# Print localparams
print("Variables and Values:")
for variable, value in localparams:
    print(f"{variable} = {value}")
'''

'''
# Print localparams without macros
print("Variables and Values:")
for variable, value in localparams_without_macros:
    print(f"{variable} = {value}")
'''

# Insert paramters

# Path to the template and the new altered file
template = "hw/newusb_regs/newusb_regs_template.hjson"
altered = "hw/newusb_regs/newusb_regs.hjson"

def create_altered_file(template, altered, localparams_without_macros):
    # Copy the template file to a new file
    shutil.copy(template, altered)
    
    # Read the contents of the new file
    with open(altered, 'r') as file:
        lines = file.readlines()
    
    # Perform replacements on lines that start with "resval:" or "count:"
    updated_lines = []
    for line in lines:
        # Only modify the line if it starts with "resval:" or "count:"
        if "resval:" in line or "count:" in line:
            # Replace each occurrence of the parameter name with its corresponding value
            for param_name, param_value in localparams_without_macros:
                # line = line.replace(f'"{param_name}"', f'"{param_value}"')
                line = line.replace(param_name, str(param_value))
        
        # Add the (possibly modified) line to the list of updated lines
        updated_lines.append(line)

    # Write the modified content back to the new file
    with open(altered, 'w') as file:
        file.writelines(updated_lines)

create_altered_file(template, altered, localparams_without_macros)

