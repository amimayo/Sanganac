.section .text.init
.global _start
.type _start, @function

_start:

    nop
    nop

    li sp, 0x00000100

    la t0, trap_vec_func
    csrw mtvec, t0

    li ra, 0
    li gp, 0
    li tp, 0

    call main

_halt:

    j _halt

.align 4

trap_vec_func:

    mret
