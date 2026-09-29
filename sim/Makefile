PREFIX = riscv32-unknown-elf
IVERILOG = iverilog
SIMDIR = .
PYTESTDIR = ../tests/test_runner.py
VENVPYTEST =  ../.venv/bin/pytest

RTLDIR = ../rtl/*.v
TBDIR = ../tb/tb.v
VVPDIR = $(SIMDIR)/sanganac.vvp

GCC = $(PREFIX)-gcc   
OBJCOPY = $(PREFIX)-objcopy  
OBJDUMP = $(PREFIX)-objdump  

CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding

TARGET = program
HEX_OUT = $(SIMDIR)/instr_program.hex 

.PHONY : all clean dump run test venv

all : $(HEX_OUT) $(VVPDIR)

$(TARGET).elf : start.S main.c linker.ld
	$(GCC) $(CFLAGS) -T linker.ld start.S main.c -o $(TARGET).elf

$(TARGET).bin : $(TARGET).elf
	$(OBJCOPY) -O binary --only-section=.text* $(TARGET).elf $(TARGET).bin

$(HEX_OUT) : $(TARGET).bin
	mkdir -p $(SIMDIR)
	od -An -v -tx4 -w4 $(TARGET).bin | tr -d ' ' > $(HEX_OUT)
	@echo "SUCCESS : $(HEX_OUT) compiled for simulation"

$(VVPDIR) : $(RTLDIR) $(TBDIR)

	$(IVERILOG) -o $(VVPDIR) $(TBDIR) $(RTLDIR)
	@echo "SUCCESS : $(VVPDIR) compiled for simulation"

run : all

	vvp $(VVPDIR)

venv:
	@if [ ! -d "../.venv" ]; then \
		echo "Creating virtual environment"; \
		python3 -m venv ../.venv; \
		../.venv/bin/pip install --upgrade pip; \
		../.venv/bin/pip install pytest cocotb cocotb-test; \
	fi

test : venv

	$(VENVPYTEST) -v $(PYTESTDIR)

dump : $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).dis

clean :
	rm -f *.o *.elf *.bin *.dis $(HEX_OUT)
