PROJECT=spi_tb
BUILD_SMT=build-smtbmc

check: $(BUILD_SMT)/$(PROJECT).smt2
	yosys-smtbmc -s z3 -t 180 --presat --dump-smt2 $(BUILD_SMT)/$(PROJECT)_bmc.smt2 --dump-vcd $(BUILD_SMT)/$(PROJECT)_bmc.vcd $(BUILD_SMT)/$(PROJECT).smt2
	yosys-smtbmc -s z3 -i -t 180 --presat --dump-smt2 $(BUILD_SMT)/$(PROJECT)_tmp.smt2 --dump-vcd $(BUILD_SMT)/$(PROJECT)_tmp.vcd $(BUILD_SMT)/$(PROJECT).smt2

$(BUILD_SMT)/$(PROJECT).smt2: spi_core.v $(PROJECT).v
	yosys -ql $(BUILD_SMT)/spi.yslog -s formal-smtbmc.ys

clean::
	rm -f $(BUILD_SMT)/spi.yslog $(BUILD_SMT)/$(PROJECT)_*.* $(BUILD_SMT)/$(PROJECT).smt2 $(BUILD_SMT)/spi_sim.*
