SHELL := bash

OUT = ./out
SEED = $$RANDOM
COMP_OPTS += +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv
v = @

SRCS += $(shell find ../rtl -name "*.*v")
SRCS += $(shell find ../uvm -name "*_pkg.sv")
SRCS += $(shell find ../tb -name "*.*v")

VERILOG = $(SRCS) $(shell find ../uvm -name "*.*v")


# Run

run: clean $(OUT)/compile.stamp
	@echo "Running (log file at $(OUT)/sim.log) ..."
	$(v)vsim -sv_lib $(UVM_DPI_HOME)/uvm_dpi tb $(SIM_OPTS) -work $(OUT)/work -do "add wave tb/DUT/*" -coverage \
		-do "coverage save -onexit -testname spi_master_test_$(SEED) out/coverage.ucdb" -sv_seed $(SEED) \
			-do "run -a;" +UVM_TESTNAME=spi_master_test -voptargs=+acc -l $(OUT)/sim.log \
				-wlf $(OUT)/sim.wlf > $(OUT)/sim.log \
					-do "layout load Simulate"

debug: clean $(OUT)/compile.stamp
	@echo "Running (log file at $(OUT)/sim.log) ..."
	$(v)vsim -sv_lib $(UVM_DPI_HOME)/uvm_dpi tb +UVM_VERBOSITY=UVM_DEBUG -work $(OUT)/work -do "add wave tb/DUT/*" -coverage \
		-do "coverage save -onexit -testname spi_master_test_$(SEED) out/coverage.ucdb" -sv_seed $(SEED) \
			-do "run -a;" +UVM_TESTNAME=spi_master_test -voptargs=+acc -l $(OUT)/sim.log \
				-wlf $(OUT)/sim.wlf > $(OUT)/sim.log \
					-do "layout load Simulate"

# Compile

$(OUT)/compile.stamp: $(VERILOG) $(OUT)/COMP_OPTS.$(subst /,,$(COMP_OPTS)) | $(OUT)
	@echo "Compiling (log file at $(OUT)/compile.log) ..."
	$(v)vlib $(OUT)/work > $(OUT)/compile.log
	$(v)vmap work $(OUT)/work >> $(OUT)/compile.log
	$(v)vmap mtiUvm /usr/local/bin/quartus-prime/questa_fse/uvm-1.2 >> $(OUT)/compile.log
	$(v)vlog -vopt -sv $(COMP_OPTS) -work work $(SRCS) >> $(OUT)/compile.log
	@touch $@

compile: ../rtl/spi_master.v
	@echo "Compiling spi_master..."
	rm -r out_verilog
	mkdir out_verilog
	$(v)vlib out_verilog/work
	$(v)vlog -vopt -work out_verilog/work ../rtl/spi_master.v

# Output directory

$(OUT):
	@mkdir -p $@

# Compilation options target
# Because we depend on this variable for compilation

$(OUT)/COMP_OPTS.$(subst /,,$(COMP_OPTS)): | $(OUT)
	$(v)rm -f $(OUT)/COMP_OPTS.*
	@touch $@


# Make coverage report
report: $(OUT)/coverage.ucdb
	vcover report -details -html $(OUT)/coverage.ucdb
	firefox ./covhtmlreport/index.html

# Clean

.PHONY: clean

clean:
	@echo "Removing $(OUT) ..."
	rm -rf $(OUT)
