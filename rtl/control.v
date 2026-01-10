module CONTROL_UNIT (
    input clk,
    input reset,

    input [31:0] pc,
    input [31:0] mem_read,
    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [63:0] rd_output,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm_ext,

    output [31:0] alu_in1,
    output [31:0] alu_in2,
    output [31:0] out, 
    output [7:0] aluop,
    output wr_en_rf,
    output wr_en_mem,
    output [31:0] mem_data_wr,
    output [31:0] mem_addr,
    output [3:0] mem_mask,
    output [31:0] jump_pc,
    output is_jump
);

    wire [1:0] byte_sel;
    assign byte_sel = rd_output[1:0]; 

    always @(*) begin
        
        alu_in1     = rs1_in;
        alu_in2     = rs2_in;
        out         = rd_output; 
        aluop       = 8'd0;
        wr_en_rf    = 0;
        wr_en_mem   = 0;
        mem_data_wr = rs2_in;
        mem_addr    = rd_output;
        mem_mask    = 4'b0000;
        jump_pc     = pc + imm_ext;
        is_jump     = 0;

        case(opcode)

        7'b0110011,7'b0010011 : begin //R-TYPE / I-TYPE
            wr_en_rf <= 1;

            if ((opcode == 7'b0110011) && (funct7 == 7'b0000001)) begin //M-TYPE
                case(funct3)

                3'b000 : begin //MUL
                    alu_in1 <= rs1_in;
                    alu_in2 <= rs2_in;
                    out <= rd_output[31:0];
                    aluop <= 8'd3;
                end
 
                3'b001 : begin //MULH
                    alu_in1 <= rs1_in;
                    alu_in2 <= rs2_in;
                    out <= rd_output[63:32];
                    aluop <= 8'd3;
                end

                3'b101 : begin //DIV
                    alu_in1 <= rs1_in;
                    alu_in2 <= rs2_in;
                    out <= rd_output;
                    aluop <= 8'd4;
                end

                3'b111 : begin //REM
                    alu_in1 <= rs1_in;
                    alu_in2 <= rs2_in;
                    out <= rd_output;
                    aluop <= 8'd5;
                end

                endcase
            end

            else begin
                case(funct3)
                
                3'b000 : begin //ADD/SUB
                    alu_in1 <= rs1_in;
                    alu_in2 <= (opcode == 7'b0010011) ? imm_ext : rs2_in; //IMM FOR I-TYPE : RS2 FOR R-TYPE
                    out <= rd_output;
                    aluop <= ((opcode == 7'b0110011) && funct7[5]) ? 8'd2 : 8'd1; //SUB:ADD
                end

                3'b001 : begin //SLL
                    alu_in1 <= rs1_in;
                    alu_in2 <= (opcode == 7'b0010011) ? imm_ext : rs2_in;
                    out <= rd_output;
                    aluop <= 8'd9;
                end

                3'b100 : begin //XOR
                    alu_in1 <= rs1_in;
                    alu_in2 <= rs2_in;
                    out <= rd_output;
                    aluop <= 8'd8;
                end

                3'b101 : begin //SRL/SRA
                    alu_in1 <= rs1_in;
                    alu_in2 <= (opcode == 7'b0010011) ? imm_ext : rs2_in;
                    out <= rd_output;
                    aluop <= (funct7[5]) ? 8'd11 : 8'd10; //SRA:SRL
                end

                3'b110 : begin //OR
                    alu_in1 <= rs1_in;
                    alu_in2 <= (opcode == 7'b0010011) ? imm_ext : rs2_in;
                    out <= rd_output;
                    aluop <= 8'd7;
                end

                3'b111 : begin //AND
                    alu_in1 <= rs1_in;
                    alu_in2 <= (opcode == 7'b0010011) ? imm_ext : rs2_in;
                    out <= rd_output;
                    aluop <= 8'd6;
                end

                endcase
            end
        end
        
        7'b0110111,7'b0010111 : begin //U-TYPE 
            wr_en_rf <= 1;

            aluop <= 0;
            out <= (opcode == 7'b0110111) ? imm_ext : pc + imm_ext;
        end

        7'b1100011 : begin //B-TYPE
            
            case(funct3)
            
            3'b000 : begin //BEQ
                alu_in1 <= rs1_in;
                alu_in2 <= rs2_in;
                aluop <= 8'd2;
                jump_pc <= pc + imm_ext;
                is_jump <= (rd_output[31:0] == 0);           
            end

            3'b001 : begin //BNE
                alu_in1 <= rs1_in;
                alu_in2 <= rs2_in;
                aluop <= 8'd2;
                jump_pc <= pc + imm_ext;
                is_jump <= (rd_output[31:0] != 0);           
            end

            //BLT
            //BGE

            endcase
        end

        7'b1101111 : begin //J-TYPE
            wr_en_rf <= 1; //JAL
            is_jump <= 1;
            jump_pc <= pc + imm_ext;
            out <= pc + 4;
        end

        7'b0100011 : begin //S-TYPE
            wr_en_mem <= 1;
            
            alu_in1 <= rs1_in;
            alu_in2 <= imm_ext;
            aluop <= 8'd1;
            mem_data_wr <= rs2_in;
            mem_addr <= rd_output[31:0];

            case(funct3)

            3'b000 : begin //SB
                case(byte_sel)

                2'b00 : mem_mask <= 4'b0001;
                2'b01 : mem_mask <= 4'b0010;
                2'b10 : mem_mask <= 4'b0100;
                2'b11 : mem_mask <= 4'b1000;

                endcase
            end 

            3'b001 : mem_mask <= (byte_sel[1]) ? 4'b1100 : 4'b0011; //SH

            3'b010 : mem_mask <= 4'b1111; ///SW

            endcase
        end

        default begin
            wr_en_rf <= 0;
            wr_en_mem <= 0;
            is_jump <=  0;
            aluop <= 8'd0;
        end

        endcase

    end

    
endmodule