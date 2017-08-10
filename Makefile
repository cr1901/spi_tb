PROJECT=spi_tb

check: $(PROJECT).smt2
	yosys-smtbmc -s z3 --dump-smt2 $(PROJECT)_bmc.smt2 --dump-vcd $(PROJECT)_bmc.vcd $(PROJECT).smt2
	yosys-smtbmc -s z3 -i --dump-smt2 $(PROJECT)_tmp.smt2 --dump-vcd $(PROJECT)_tmp.vcd $(PROJECT).smt2
	
$(PROJECT).smt2: spi_core.v $(PROJECT).v
	yosys -ql spi.yslog -s formal.ys

clean::
	rm -f spi.yslog $(PROJECT)_*.* $(PROJECT).smt2
