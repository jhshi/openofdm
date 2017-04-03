###############################################################################
#
# ICARUS VERILOG & GTKWAVE MAKEFILE
# MADE BY WILLIAM GIBB FOR HACDC
# williamgibb@gmail.com
# 
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make simulate" - compiles your design+TB & simulates your design
#	"make display" - compiles, simulates and displays waveforms
# 
###############################################################################

#TOOL INPUT
SRC = $(wildcard *.v) $(wildcard *.mif) $(wildcard *.coe)
MODULE_LIST = dot11_modules.list

TESTBENCH = dot11_tb.v
COMPILER_OUT = dot11.out
SIM_OUT = dot11.vcd

###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

#TOOL OPTIONS
COMPILER_FLAGS = -v -c $(MODULE_LIST) -o $(COMPILER_OUT) -DDEBUG_PRINT
SIMULATOR_FLAGS = -v -n
###############################################################################

all: compile simulate

#MAKE DIRECTIVES
compile: $(COMPILER_OUT)

simulate: $(COMPILER_OUT) $(SIM_OUT)

$(COMPILER_OUT): $(TESTBENCH) $(SRC)
	$(COMPILER) $(COMPILER_FLAGS) $(TESTBENCH)

$(SIM_OUT): $(COMPILER_OUT)
	$(SIMULATOR) $(SIMULATOR_FLAGS) $(COMPILER_OUT) 

clean:
	rm -rfv $(COMPILER_OUT) $(SIM_OUT)

.PHONY: clean
