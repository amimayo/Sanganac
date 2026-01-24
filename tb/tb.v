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
        
        #500;

        // ABCDE537   00: LUI X10, 0XABCDE      X10 = 0XABCDE000
        // 00A00093   04: ADDI X1, X0, 10       X1 = 10
        // 00300113   08: ADDI X2, X0, 3        X2 = 3
        // 002081B3   0C: ADD X3, X1, X2        X3 = 13
        // 40208233   10: SUB X4, X1, X2        X4 = 7
        // 022082B3   14: MUL X5, X1, X2        X5 = 30
        // 0220D333   18: DIV X6, X1, X2        X6 = 3
        // 0220F3B3   1C: REM X7, X1, X2        X7 = 1
        // 0023D433   20: SRL X8, X7, X2        X8 = 1 >> 3 = 0
        // 00552023   24: SW  X5, 0X10          STORE X5 (30) AT DATA MEMORY ADDRESS 0
        // 00052483   28: LW  X9, 0X10          LOAD FROM DATA MEMORY ADDRESS 0 INTO X9
        // 00928663   2C: BEQ X5, X9, 12        IF 30 == 30, JUMP +12 BYTES TO PC 38
        // 00100513   30: ADDI X10, X0, 1       TRAP: SHOULD BE SKIPPED
        // 00100513   34: ADDI X10, X0, 1       TRAP: SHOULD BE SKIPPED
        // 01E00613   38: ADDI X12, X0, 30      SUCCESS: X12 = 30
        // 0000006F   3C: JAL X0, 0             INFINITE LOOP

        $display("Simulation now completed.");

        $display("======================================================");
        $display("REGISTER FILE :"); 
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d : %h", i, uut.sanganac.regfile.regfile[i]);
        end
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