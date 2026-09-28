PREFIX = riscv32-unknown-elf

GCC = $(PREFIX)-gcc   
OBJCOPY = $(PREFIX)-objcopy  
OBJDUMP = $(PREFIX)-objdump  

CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding

TARGET = program
HEX_OUT = ./sim/instr_program.hex 

.PHONY : all clean dump

all : $(HEX_OUT)

$(TARGET).elf : start.S main.c linker.ld
	$(GCC) $(CFLAGS) -T linker.ld start.S main.c -o $(TARGET).elf

$(TARGET).bin : $(TARGET).elf
	$(OBJCOPY) -O binary --only-section=.text* $(TARGET).elf $(TARGET).bin

$(HEX_OUT) : $(TARGET).bin
	mkdir -p ./sim
	od -An -v -tx4 -w4 $(TARGET).bin | tr -d ' ' > $(HEX_OUT)
	@echo "SUCCESS : $(HEX_OUT) compiled for simulation"

dump : $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).dis

clean :
	rm -f *.o *.elf *.bin*.dis $(HEX_OUT)
