module INSTRMEM (
    input [31:0] instr_addr,
    output [31:0] instr
);

    reg [31:0] instrmem [0:511];

    initial begin
    $readmemh("./sim/instr_program.hex", instrmem);
    end

    assign instr = instrmem[instr_addr >> 2];
        
endmodule