module INSTRMEM (
    input [31:0] instr_addr,
    output [31:0] instr
);

    reg [31:0] instrmem [0:511];
    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            instrmem[i] = 32'h0;
        end 
        $readmemh("../sim/instr_program.hex", instrmem);
    end

    assign instr = instrmem[instr_addr >> 2]; //Instruction Memory Read
        
endmodule