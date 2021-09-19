
######################################################################
# Set up variables

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -Os -x-assign 0
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
#VERILATOR_FLAGS += --coverage
#VERILATOR_FLAGS += -Wno-STMTDLY -Wno-PINCONNECTEMPTY -Wno-CASEINCOMPLETE -Wno-WIDTH -Wno-UNOPTFLAT
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt
VERILATOR_FLAGS += --top-module testbench
VERILATOR_FLAGS += --timescale-override 1ns/1ps
VERILATOR_FLAGS += -Wno-UNUSED


RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32i

SHELL := /bin/bash
VERILATOR = verilator
IVERILOG = iverilog
VVP = vvp

TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-
PATH:=$(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin:$(PATH)

WORKINGDIR = $(shell pwd)

CORE_MODULES = $(shell ls $(WORKINGDIR)/src/rtl/rv_core_sc_mem_inf/*.v)

CORE_TESTBENCH = $(WORKINGDIR)/testbench.v

# Input files for Verilator
#VERILATOR_INPUT = -f input.vc src/rtl/ sim_main.cpp
VERILATOR_INPUT = $(CORE_MODULES) $(CORE_TESTBENCH) sim_main.cpp
RVTEST_MEMS = $(shell ls $(WORKINGDIR)/mem/hex/*.hex)
VERILATOR_FLAGS += -I$(WORKINGDIR)/src/rtl/rv_core_sc_mem_inf/ 

IVLG_FLAGS += -Wall



alltests: Vtestbench 
	@echo "##############################################################"
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vtestbench +trace
	@echo ""
	@echo ""

alltests_vcd: testbench.vvp
	@echo "##############################################################"
	@echo "Running testbench.vvp with all riscv-tests and VCD gen."
	$(VVP) -N $< $(RVTEST_MEMS) -I$(WORKINGDIR)/mem/hex +runall +vcd
	@echo ""
	@echo ""


Vtestbench: testmems
	@echo "##############################################################"
	@echo "-- VERILATE ----------------"
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	@echo
	@echo "-- BUILD -------------------"
# To compile, we can either
# 1. Pass --build to Verilator by editing VERILATOR_FLAGS above.
# 2. Or, run the make rules Verilator does:
#	$(MAKE) -j -C obj_dir -f Vclarvi_sim.mk
# 3. Or, call a submakefile where we can override the rules ourselves:
	$(MAKE) -j -C obj_dir -f ../Makefile_obj 
	@echo ""
	@echo ""

testmems: 
	@echo "##############################################################"
	@echo "Compiling, linking, and generating mem files for riscv-tests."
	@echo "Memory files will be placed into /mem/"
	@echo "Dump files will be placed into /mem/dump"
	chmod +x ./scripts/memgen.sh
	source ./scripts/memgen.sh
	@echo ""
	@echo ""

.PHONY: clean
clean:
	rm -rf testbench.vvp
	rm -rf testbench.vcd
	rm -r  mem

