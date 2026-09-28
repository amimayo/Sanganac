OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {

    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 512

    RAM (rw) : ORIGIN = 0x00000000, LENGTH = 2K

}

SECTIONS {

    .text : {
        _start = .;
        *(.text.init)
        *(.text .text.*)
        . = ALIGN(4);
    } > ROM

    .rodata : {
        . = ALIGN(4);
        *(.rodata .rodata.*)
        . = ALIGN(4);
    } > ROM

    .data : {
        . = ALIGN(4);
        *(.data .data.*)
        . = ALIGN(4);
    } > RAM

    .bss : {
        . = ALIGN(4);
        *(.bss .bss.*)
        . = ALIGN(4);
    } > RAM

    _end = .;

}