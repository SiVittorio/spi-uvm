SHELL := bash

OUT = ./out
SEED = $$RANDOM
COMP_OPTS += +incdir+../test
v = @

SRCS += $(shell find ../rtl -name "*.*v")
SRCS += $(shell find ../uvm -name "*_pkg.sv")
SRCS += $(shell find ../tb -name "*.*v")

VERILOG = $(SRCS) $(shell find ../uvm -name "*.*v")


# Run

run: clean $(OUT)/compile.stamp
	@echo "Running (log file at $(OUT)/sim.log) ..."
	$(v)vsim tb $(SIM_OPTS) -work $(OUT)/work -do "add wave tb/DUT/*" -coverage \
		-do "coverage save -onexit -testname spi_master_test_$(SEED) out/coverage.ucdb" -sv_seed $(SEED) \
			-do "run -a;" +UVM_TESTNAME=spi_master_test -voptargs="+acc +cover=bcest" -l $(OUT)/sim.log \
				-wlf $(OUT)/sim.wlf > $(OUT)/sim.log

debug: clean $(OUT)/compile.stamp
	@echo "Running (log file at $(OUT)/sim.log) ..."
	$(v)vsim tb +UVM_VERBOSITY=UVM_DEBUG -work $(OUT)/work -do "add wave tb/DUT/*" -coverage \
		-do "coverage save -onexit -testname spi_master_test_$(SEED) out/coverage.ucdb" -sv_seed $(SEED) \
			-do "run -a;" +UVM_TESTNAME=spi_master_test -voptargs="+acc +cover=bcest" -l $(OUT)/sim.log \
				-wlf $(OUT)/sim.wlf > $(OUT)/sim.log

# Compile

$(OUT)/compile.stamp: $(VERILOG) $(OUT)/COMP_OPTS.$(subst /,,$(COMP_OPTS)) | $(OUT)
	@echo "Compiling (log file at $(OUT)/compile.log) ..."
	$(v)vlib $(OUT)/work > $(OUT)/compile.log
	$(v)vmap work $(OUT)/work >> $(OUT)/compile.log
	$(v)vmap mtiUvm /tools/Mentor/questasim/uvm-1.2 >> $(OUT)/compile.log
	$(v)vlog -sv $(COMP_OPTS) -work work $(SRCS) >> $(OUT)/compile.log
	@touch $@

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
