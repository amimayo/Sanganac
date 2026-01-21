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

        // 00A00093 ADDI x1, x0, 10
        // 01400113 ADDI x2, x0, 20
        // 002081B3 ADD x3, x1, x2
        // 00302023 SW x3, 0(x0)
        // 00002203 LW x4, 0(x0)
        // 0000006F JAL x0, 0 (Infinite Loop)

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