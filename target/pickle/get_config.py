import sys
import time
from pyslang import *

class ModuleVisitor:
    def __init__(self, file_in: str):
        self.tree = SyntaxTree.fromText(file_in)
        self.comp = Compilation()
        self.comp.addSyntaxTree(self.tree)
        # Analysis results; contains per-transform dicts indexed by *syntax source start offsets*!
        # self.compinfo = defaultdict(dict)
        # self.compinfo['__eval'] = EvalContext(self.comp)
        # self.compinfo['__iterate'] = self._iterate_member

    def traverse(self) -> str:
        # Analyze compilation first and collect info
        self.comp.getRoot().visit(self._comp_visit)
        #return self._rewrite_member(self.tree.root)

    def _comp_visit(self, sym):
        print(sym)
        #if isinstance(sym, AssignmentExpression):
        #    analyze_assignment(self.compinfo, sym)
        #elif isinstance(sym, Expression):
        #    analyze_expression(self.compinfo, sym)

def main(file_in: str, top_module: str):
    ModuleVisitor(file_in).traverse()



# TODO: cmdline parser!
if __name__ == '__main__':
    sys.exit(main('cheshire_soc.sv', 'cheshire_soc'))
