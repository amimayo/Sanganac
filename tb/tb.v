`timescale 1ns/1ps

module tb ();
    
    reg clk;
    reg reset;
    integer i;

    TOP uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        reset = 1;
        #50 reset = 0;
        
        #2000;

        // ABCDE537 : 00: LUI X10, 0XABCDE      X10 = 0XABCDE000
        // 00A00093 : 04: ADDI X1, X0, 10       X1 = 10
        // 00300113 : 08: ADDI X2, X0, 3        X2 = 3
        // 002081B3 : 0C: ADD X3, X1, X2        X3 = 13
        // 40208233 : 10: SUB X4, X1, X2        X4 = 7
        // 022082B3 : 14: MUL X5, X1, X2        X5 = 30
        // 0220D333 : 18: DIV X6, X1, X2        X6 = 3
        // 0220F3B3 : 1C: REM X7, X1, X2        X7 = 1
        // 0023D433 : 20: SRL X8, X7, X2        X8 = 0
        // 00552023 : 24: SW  X5, 0(X10)        STORE 30 AT ADDR 0XABCDE000
        // 00052483 : 28: LW  X9, 0(X10)        LOAD 30 INTO X9
        // 00928663 : 2C: BEQ X5, X9, 12        IF 30==30, JUMP TO PC 38
        // 00100513 : 30: ADDI X10, X0, 1       TRAP: SKIPPED
        // 00100513 : 34: ADDI X10, X0, 1       TRAP: SKIPPED
        // 01E00613 : 38: ADDI X12, X0, 30      SUCCESS: X12 = 30
        // 0000100F : 3C: FENCE                 NOP
        // 05400793 : 40: ADDI X15, X0, 84      X15 = 84 (TARGET PC 0X54)
        // 00078067 : 44: JALR X1, X15, 0       JUMP TO PC 84, LINK X1 = 72 (0X48)
        // 00100513 : 48: ADDI X10, X0, 1       JALR TRAP: SKIPPED
        // 00100513 : 4C: ADDI X10, X0, 1       JALR TRAP: SKIPPED
        // 00100513 : 50: ADDI X10, X0, 1       JALR TRAP: SKIPPED
        // 00D00693 : 54: ADDI X13, X0, 13      JALR SUCCESS: X13 = 13
        // 0000100F : 58: FENCE                 NOP
        // 07000293 : 5C: ADDI X5, X0, 112      X5 = 112 (HANDLER ADDR 0X70)
        // 30529073 : 60: CSRRW X0, MTVEC, X5   SET MTVEC = 112
        // 00100073 : 64: EBREAK                TRAP: JUMP TO PC 112
        // 0000006F : 68: JAL X0, 0             HALT (INFINITE LOOP)
        // 00000000 : 6C: PADDING               NOP
        // 00100213 : 70: ADDI X4, X4, 1        INCREMENT TRAP COUNTER (X4)
        // 00054583 : 74: LBU X11, 0(X10)       LOAD UNSIGNED BYTE (30)
        // 30200073 : 78: MRET                  RETURN TO PC 104 (PC 68)
        // 0000100F : 7C: FENCE                 HALT

        $display("Simulation now completed.");

        $display("======================================================");
        $display("REGISTER FILE :"); 
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d : %h", i, uut.sanganac.regfile.regfile[i]);
        end
        $display("======================================================");

        $display("CONTROL STATUS REGISTERS :"); 
            $display("MSTATUS : %h", uut.sanganac.csr.mstatus);
            $display("MTVEC   : %h", uut.sanganac.csr.mtvec);
            $display("MEPC    : %h", uut.sanganac.csr.mepc);
            $display("MCAUSE  : %h", uut.sanganac.csr.mcause);
        $display("======================================================");

        $display("");
        $display("======================================================");
        $display("INSTRUCTION MEMORY :");
        for (i = 0; i < 20; i = i + 1) begin
            $display("%h : %h", i*4, uut.sanganac.instrmem.instrmem[i]);
        end
        $display("======================================================");

        $display("");
        $display("======================================================");
        $display("DATA MEMORY :");
        for (i = 0; i < 20; i = i + 1) begin
            $display("%h : %h", i*4, uut.sanganac.datamem.datamem[i]);
        end
        $display("======================================================");

        $display("");

        $finish;

    end

    initial begin
        $monitor("Time : %0t | Reset : %b | PC : %h | Instruction : %h", 
                 $time, reset, uut.sanganac.pc_current, uut.sanganac.instr);
    end

endmodule