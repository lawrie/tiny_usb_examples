F32C-COMPILER-PATH=/opt/riscv32i/bin
# EDIT 'F32C-COMPILER-PATH' PATH AS NECESSARY!
RISCV32-GCC=$(F32C-COMPILER-PATH)/riscv32-unknown-elf-gcc
RISCV32-OBJCOPY=$(F32C-COMPILER-PATH)/riscv32-unknown-elf-objcopy

firmware.hex:

firmware.elf: sections.lds start.s firmware.c
	$(RISCV32-GCC) -march=rv32i -mabi=ilp32 -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s firmware.c

firmware.bin: firmware.elf
	$(RISCV32-OBJCOPY) -O binary firmware.elf /dev/stdout > firmware.bin

firmware.hex: firmware.bin
	python3 makehex.py $^ 4096 > $@
