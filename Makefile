PSET := pset09

test: $(PSET)
	./$(PSET)

$(PSET): ./modules/testbench.v ./modules/cpu_top.v ./modules/core.v ./modules/alu.v ./modules/reg_file.v ./modules/control.v ./modules/rom.v ./modules/mem_ctrl.v
	iverilog $^ -o $@

clean:
	rm -f $(PSET)

samples:
	$(MAKE) -C samples/

help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help samples
