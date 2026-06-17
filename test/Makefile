# Simple Makefile for simulation with Icarus Verilog
# Usage:
#   make sim        - build + run testbench (default)
#   make clean

# Makefile for barrel_shifter test (placed in test/ per project rules)
# Usage (recommended):
#   From repo root:        make -C test sim
#   From inside test/:     make sim
#   Clean:                 make -C test clean

TOP      = barrel_shifter
TB       = tb_$(TOP)
SIM      = tb_sim
IVERILOG = iverilog
VVP      = vvp

# Paths after moving into the proper repo layout
DUT_DIR  = ../modules
DUT      = $(DUT_DIR)/$(TOP).v
TB_FILE  = $(TB).v

.PHONY: sim clean

sim: $(SIM)
	$(VVP) $(SIM)

$(SIM): $(DUT) $(TB_FILE)
	$(IVERILOG) -Wall -g2012 -o $@ $(DUT) $(TB_FILE)

clean:
	rm -f $(SIM) *.vcd tb_sim

waves: $(SIM)
	$(VVP) $(SIM)
	gtkwave $(TOP).vcd &
