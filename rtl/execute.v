module EXECUTE (

    input [31:0] pc,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] imm_ext,
    input [6:0] opcode,
    input [2:0] funct3,
    input [7:0] alucode,
    input alu_src_a,
    input alu_src_b,
    input is_b_instr,
    input is_jump,
    input is_j_instr,
    input [1:0] forward_a,
    input [1:0] forward_b,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_wr_data,

    output [63:0] alu_result,
    output [31:0] mem_data_wr,
    output reg branch_taken,
    output [31:0] jump_pc
    
);

    reg [31:0] forwarded_a;
    reg [31:0] forwarded_b;
    wire [31:0] alu_input_a;
    wire [31:0] alu_input_b;

    always @(*) begin

        case (forward_a)

            2'b00 : forwarded_a = rs1_data; // NO
            2'b01 : forwarded_a = mem_wb_wr_data; // MEM_WB
            2'b10 : forwarded_a = ex_mem_alu_result; // EX_MEM 
            default : forwarded_a = rs1_data;

        endcase
        
    end

    always @(*) begin

        case (forward_b)

            2'b00 : forwarded_b = rs2_data; // NO
            2'b01 : forwarded_b = mem_wb_wr_data; // MEM_WB
            2'b10 : forwarded_b = ex_mem_alu_result; // EX_MEM 
            default : forwarded_b = rs2_data;

        endcase
        
    end

    assign mem_data_wr = forwarded_b;

    assign alu_input_a = (opcode == 7'b0110111) ? 32'b0 : (alu_src_a ? pc : forwarded_a);
    assign alu_input_b = alu_src_b ? imm_ext : forwarded_b;

    ALU alu (
        .alucode(alucode),
        .rs1(alu_input_a),
        .rs2(alu_input_b),
        .rd(alu_result)
    );

    always @(*) begin

        branch_taken = 0;

        if (is_jump) begin
            branch_taken = 1;
        end
        else if (is_b_instr) begin
          
            case (funct3)

                3'b000 : branch_taken = (forwarded_a == forwarded_b); // BEQ
                3'b001 : branch_taken = (forwarded_a != forwarded_b); // BNE
                3'b100 : branch_taken = ($signed(forwarded_a) < $signed(forwarded_b)); // BLT
                3'b101 : branch_taken = ($signed(forwarded_a) >= $signed(forwarded_b)); // BGE
                3'b110 : branch_taken = (forwarded_a < forwarded_b); // BLTU
                3'b111 : branch_taken = (forwarded_a >= forwarded_b); // BGEU
                default : branch_taken = 0;

            endcase

        end

    end

    assign jump_pc = ((is_j_instr ? forwarded_a : pc) + imm_ext) & ~32'b1;

endmodule