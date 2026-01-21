module DECODER (
    input [31:0] instr,
    output [4:0] rs1_addr,
    output [4:0] rs2_addr,
    output [4:0] rd_addr,
    output [6:0] opcode,
    output [2:0] funct3,
    output [6:0] funct7,
    output reg [31:0] imm_ext
);

    assign opcode = instr[6:0];
    assign rd_addr = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7 = instr[31:25];

    //Immediate Value Extension

    always @(*) begin
        
        if ((opcode == 7'b0010011) || (opcode == 7'b0000011)) begin 
            imm_ext = {{20{instr[31]}}, instr[31:20]} ; end //I-Type Instruction
        else if ((opcode == 7'b0110111) || (opcode == 7'b0010111)) begin 
             imm_ext = {instr[31:12], 12'b0} ; end //U-Type Instruction
        else if ((opcode == 7'b1100011)) begin 
             imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0} ; end //B-Type Instruction 
        else if ((opcode == 7'b1101111)) begin 
             imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0} ; end //J-Type Instruction
        else if ((opcode == 7'b0100011)) begin 
            imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]} ; end //S-Type Instruction
        else begin
            imm_ext = 32'b0; end

    end
  
endmodule