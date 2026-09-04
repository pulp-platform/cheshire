# hw-flow.mk
# Template: Bender file-list generation + Verilator lint.
# Copy into a project's root, fill in the four values below by hand.
# Fully self-contained, nothing else required.

# If any recipe below fails partway through, delete whatever target file
# it was writing rather than leaving a corrupt/empty artifact with a
# fresh timestamp, which would otherwise fool the next `make` invocation
# into thinking that file is already up to date.
.DELETE_ON_ERROR:
BENDER := $(HOME)/.cargo/bin/bender
# --- Fill in per project ---
BENDER_TAGS_BASE := -t rtl -t cva6 -t cv64a6_imafdchsclic_sv39_wb
BENDER_TAGS_SIM  := -t sim -t test
TOP_MODULE       := tb_cheshire_soc
VLT_FILE         := # path to a Verilator waiver file, or leave empty

# --- Bender -> Verilator lint flow ---
verilator_filelist.f: Bender.yml Bender.lock $(MAKEFILE_LIST)
	$(BENDER) script verilator $(BENDER_TAGS_BASE) $(BENDER_TAGS_SIM) > $@

.PHONY: verilator-lint
verilator-lint: verilator_filelist.f
	verilator --lint-only -Wall $(VLT_FILE) --top-module $(TOP_MODULE) -f verilator_filelist.f