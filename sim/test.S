.section .text
.global _start

_start:

    lui x10, 0xABCDE        # x10 = 0xABCDE000
    
    li x1, 10               # x1 = 10 (0x0A)
    li x2, 3                # x2 = 3

    add x3, x1, x2          # x3 = 13 (0x0D)
    sub x4, x1, x2          # x4 = 7
    
    mul x5, x1, x2          # x5 = 30 (0x1E)
    div x6, x1, x2          # x6 = 3
    rem x7, x1, x2          # x7 = 1
    
    srl x8, x7, x2          # x8 = 0
    
    sw x5, 0(x10)           # Store 30 into data memory at address 0xABCDE000
    lw x9, 0(x10)           # Load 30 back into x9
    
    beq x5, x9, branch_target 
    
    li x10, 1
    li x10, 1

branch_target:

    li x12, 30              # x12 = 30
    fence                   
    
    li x15, 0x54            # Load target address 84 (0x54) into x15
    jalr x1, x15, 0         # Jump to x15 (0x54), save return address in x1
    
    li x10, 1
    li x10, 1
    li x10, 1

jalr_target:

    li x13, 13              # x13 = 13
    fence                   
    
    li x5, 0x70             # Load handler base address 112 (0x70) into x5
    csrrw x0, mtvec, x5     # Set mtvec = 0x70
    
    ebreak                  # Triggers environment breakpoint and Jumps to mtvec (0x70)

halt_loop:

    jal x0, halt_loop       # Jump (PC=0x68)

    nop

.org 0x70
trap_handler:
    
    addi x16, x16, 1        # Increment trap counter (x16 = 1)
    
    lbu x11, 0(x10)         # x11 = 30 (0x1E)
    
    mret                    # Return to the instruction following ebreak (PC=0x68)
    fence