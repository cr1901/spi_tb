PROJECT=spi_tb

check: $(PROJECT).smt2
	yosys-smtbmc -s z3 --dump-smt2 $(PROJECT)_bmc.smt2 --dump-vcd $(PROJECT)_bmc.vcd $(PROJECT).smt2
	yosys-smtbmc -s z3 -i --dump-smt2 $(PROJECT)_tmp.smt2 --dump-vcd $(PROJECT)_tmp.vcd $(PROJECT).smt2
	
sim: spi_sim.vvp
	vvp spi_sim.vvp
	
spi_sim.vvp: spi_core.v $(PROJECT).v
	iverilog -o spi_sim.vvp spi_core.v spi_tb.v
	
$(PROJECT).smt2: spi_core.v $(PROJECT).v
	yosys -ql spi.yslog -s formal.ys

clean::
	rm -f spi.yslog $(PROJECT)_*.* $(PROJECT).smt2 spi_sim.*
