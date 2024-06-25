PROJ=beta
TOP_MODULE=top

# optionally set the name of a module used for simulation, and number of cycles to simulate.
TOP_SIMULATION_MODULE=sim
# with a 48 MHz clock, this would be one ms of simulation.
SIMULATION_CYCLES=48000

DO_SIMULATION=yes

# By default, we will read all verilog files (.v) in this directory.
VERILOG_FILES=$(wildcard src/*.v)

RM         = rm -rf
COPY       = cp -a
PATH_SEP   = /

all: $(PROJ).vcd
	
# We don't actually need to do anything to verilog files.
# This explicitly empty recipe is merely referenced from
# the %.ys recipe below. Since it depends on those files,
# make will check them for modifications to know if it needs to rebuild.
%.v: ;

# Build the yosys script.
# This recipe depends on the actual verilog files (defined in $(VERILOG_FILES))
# Also, this recipe will generate the whole script as an intermediate file.
# The script will call read_verilog for each file listed in $(VERILOG_FILES),
%.ys: $(VERILOG_FILES)
	$(file >$@)
	$(foreach V,$(VERILOG_FILES),$(file >>$@,read_verilog -sv $V))
	$(if $(DO_SIMULATION), \
		$(file >>$@,prep -top $(TOP_SIMULATION_MODULE)) \
		$(file >>$@,sim -clock clk -n $(SIMULATION_CYCLES) -vcd $(basename $@).vcd) \
	)

# For the %.vcd target, set DO_SIMULATION, so the sim lines will be used in generating the .ys
# Then, run yosys with that script.
%.vcd: DO_SIMULATION=yes
%.vcd: %.ys
	yosys -s "$<"

# Run the simulation to create the .vcd file, then view it with gtkwave.
# If you don't have gtkwave, you can get it from http://gtkwave.sourceforge.net/
sim: $(PROJ).vcd
	gtkwave "$(PROJ).vcd"

clean:
	$(RM) -f $(PROJ).svf $(PROJ).bit $(PROJ)_out.config $(PROJ).json $(PROJ).dfu $(PROJ).vcd
.DELETE_ON_ERROR: 
.PHONY: sim clean show
