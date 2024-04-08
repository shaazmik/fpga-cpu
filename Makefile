PSET := pset
MODULE_PATH := ./modules

test: $(PSET)
	bin/$(PSET)

$(PSET): $(MODULE_PATH)/alu.v
	iverilog $^ -o bin/$@

clean:
	rm -f bin/$(PSET)


help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help samples