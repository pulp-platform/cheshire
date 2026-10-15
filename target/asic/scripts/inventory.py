#!/usr/bin/env python3
# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Technology-agnostic inventory of an elaborated design.

Lists every `tc_sram` with its shape, every other `tc_*` tech cell, and every
clock-domain-crossing or clock primitive. A technology target uses it to know
which SRAM shapes need macros and which tech cells it must provide; the
constraints use it to know which crossings exist.

Elaborates with pyslang; arguments not listed below are passed to slang.
"""

import argparse
import json
import os
import re
import sys
from collections import Counter, defaultdict

from pyslang import DiagnosticEngine
from pyslang.ast import SymbolKind as SK
from pyslang.driver import CommandLineOptions, Driver

SRAM_DEF = 'tc_sram'
SRAM_PARAMS = ('NumWords', 'DataWidth', 'ByteWidth', 'NumPorts', 'Latency', 'SimInit', 'ImplKey')
# Crossing and clock primitives, including vendored copies (e.g. `clint_sync`)
# and SpinalHDL-generated ones (e.g. `UsbOhciAxi4_BufferCC_8`)
CROSSING_RE = re.compile(r'(^|_)(cdc|sync|rstgen)(_|$)|^clk_|BufferCC|CCByToggle|FifoCC|CtrlCc')
# Synchronous FIFOs (e.g. OpenTitan `prim_fifo_sync`) are not crossings
NOT_CROSSING_RE = re.compile(r'fifo_sync')


def param_value(sym):
    """Parameter value as int if integral (e.g. `32'd256`), else as string."""
    val = getattr(sym, 'value', None)
    if val is None:
        return None
    text = str(val).strip()
    if text.startswith('"'):
        return text.strip('"')
    size, tick, rest = text.partition("'")
    if not tick:
        return int(size) if size.lstrip('-').isdigit() else text
    rest = rest.lstrip('sS')
    base = {'d': 10, 'h': 16, 'b': 2, 'o': 8}.get(rest[:1].lower())
    try:
        return int(rest[1:].replace('_', ''), base)
    except (TypeError, ValueError):
        return text


def subsystem(path, below):
    """First named instance below `below` in a hierarchical path."""
    parts = path.split('.')
    if below in parts:
        parts = parts[parts.index(below) + 1:]
    for part in parts:
        if part.startswith('i_'):
            return part
    return parts[0] if parts else path


class Inventory:

    def __init__(self):
        self.srams = []
        self.tech_cells = defaultdict(list)
        self.crossings = defaultdict(list)

    def visit_instance(self, inst):
        name = inst.definition.name
        path = inst.hierarchicalPath
        if name == SRAM_DEF:
            params = {p.name: param_value(p) for p in inst.body.parameters if p.name in SRAM_PARAMS}
            self.srams.append({'path': path, **params})
            return  # Behavioural internals are of no interest
        if name.startswith('tc_'):
            self.tech_cells[name].append(path)
        elif CROSSING_RE.search(name) and not NOT_CROSSING_RE.search(name):
            self.crossings[name].append(path)
            return  # Count the outermost primitive only
        self.walk(inst.body)

    def walk(self, scope):
        for member in scope:
            kind = member.kind
            if kind == SK.Instance:
                if member.isModule:
                    self.visit_instance(member)
            elif kind == SK.GenerateBlock:
                if not member.isUninstantiated:
                    self.walk(member)
            elif kind in (SK.GenerateBlockArray, SK.InstanceArray):
                self.walk(member)

    def to_dict(self):
        return {
            'srams': self.srams,
            'tech_cells': dict(self.tech_cells),
            'crossings': dict(self.crossings)
        }


def sram_shape(sram):
    return (sram['NumWords'], sram['DataWidth'], sram['ByteWidth'], sram['NumPorts'],
            sram['Latency'])


def print_summary(inv, below):
    shapes = defaultdict(list)
    for sram in inv.srams:
        shapes[sram_shape(sram)].append(sram['path'])
    total_bits = 0
    print(f'== SRAMs: {len(inv.srams)} instances, {len(shapes)} shapes')
    print(f'{"words":>6} {"width":>6} {"byte":>5} {"ports":>5} {"lat":>4} {"count":>5}'
          f' {"KiB each":>9}  where')
    for shape, paths in sorted(shapes.items(), key=lambda kv: (-kv[0][0] * kv[0][1], kv[0])):
        words, width, byte, ports, lat = shape
        total_bits += words * width * len(paths)
        where = Counter(subsystem(p, below) for p in paths)
        where = ', '.join(f'{k} x{v}' for k, v in sorted(where.items()))
        print(f'{words:>6} {width:>6} {byte:>5} {ports:>5} {lat:>4} {len(paths):>5}'
              f' {words * width / 8192:>9.2f}  {where}')
    print(f'   total {total_bits / 8192:.2f} KiB')
    for title, cells in (('tech cells', inv.tech_cells), ('crossing/clock primitives',
                                                          inv.crossings)):
        print(f'== {title}: {sum(len(v) for v in cells.values())} instances')
        for name, paths in sorted(cells.items()):
            where = Counter(subsystem(p, below) for p in paths)
            where = ', '.join(f'{k} x{v}' for k, v in sorted(where.items()))
            print(f'   {name:<28} {len(paths):>4}  {where}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json', help='write the full inventory to this file')
    parser.add_argument('--below',
                        default='i_cheshire_soc',
                        help='instance whose children group the summary')
    parser.add_argument('--all-diags',
                        action='store_true',
                        help='report warnings too, not only errors')
    # Any other argument is passed to slang
    args, slang_args = parser.parse_known_args()

    driver = Driver()
    driver.addStandardArgs()
    cmdline = ' '.join(['slang'] + slang_args)
    if not (driver.parseCommandLine(cmdline, CommandLineOptions())
            and driver.processOptions() and driver.parseAllSources()):
        sys.exit('error: could not parse sources')
    comp = driver.createCompilation()
    diags = comp.getAllDiagnostics()
    errors = [d for d in diags if d.isError()]
    shown = diags if args.all_diags else errors
    if shown:
        print(DiagnosticEngine.reportAll(driver.sourceManager, shown), file=sys.stderr)
    print(f'== elaboration: {len(errors)} errors, {len(diags) - len(errors)} warnings')
    if errors:
        sys.exit('error: elaboration failed')

    inv = Inventory()
    for top in comp.getRoot().topInstances:
        inv.walk(top.body)

    print_summary(inv, args.below)
    if args.json:
        # Write atomically: concurrent runs may share the output
        tmp = f'{args.json}.{os.getpid()}'
        with open(tmp, 'w', encoding='utf-8') as file:
            json.dump(inv.to_dict(), file, indent=2)
        os.replace(tmp, args.json)


if __name__ == '__main__':
    main()
