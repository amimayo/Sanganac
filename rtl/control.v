module CONTROL_UNIT (
    input clk,
    input reset,

    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [11:0] csr_addr,
    input mie_out,
    input ext_int,

    output reg [7:0] alucode,
    output reg alu_src_a,
    output reg alu_src_b, 
    output reg wr_en_rf,
    output reg wr_en_mem,
    output reg read_en_mem,
    output reg is_b_instr,
    output reg is_jump,
    output reg is_j_instr,
    output reg [1:0] wb_sel,

    output reg [1:0] csr_op,
    output reg csr_wr_en,
    output reg csr_read_en,
    output reg trap_take,
    output reg mret_take,
    output reg [31:0] trap_cause
);

    always @(*) begin
        
        alucode     = 8'b0;
        alu_src_a   = 1'b0; // alu_src_a = 0 : rs1 ; alu_src_a = 1 : pc
        alu_src_b   = 1'b0; // alu_src_b = 0 : rs2 ; alu_src_b = 1 : imm_ext
        wr_en_rf    = 0;
        wr_en_mem   = 0;
        read_en_mem = 0;
        is_b_instr  = 0;
        is_jump     = 0;
        is_j_instr  = 0;
        wb_sel      = 2'b00;
        csr_op      = 2'b00;
        csr_wr_en   = 0;
        csr_read_en = 0;
        trap_take   = 0;
        mret_take   = 0;
        trap_cause  = 32'b0;

        if (ext_int & mie_out) begin  //INTERRUPT
            trap_take = 1;
            is_jump = 1;
            trap_cause = 32'h8000000B; //MEI
        end

        else begin

            case(opcode)

            7'b0110011,7'b0010011 : begin //R-TYPE / I-TYPE
                wr_en_rf = 1;
                alu_src_b = (opcode == 7'b0010011) ? 1 : 0; // imm_ext for I-Type : rs2 for R-Type

                if ((opcode == 7'b0110011) && (funct7 == 7'b0000001)) begin //M-TYPE
                    case(funct3)

                    3'b000 : begin //MUL
                        alucode = 8'd3;
                    end
    
                    3'b001 : begin //MULH
                        alucode = 8'd16;
                    end

                    3'b010 : begin //MULHSU
                        alucode = 8'd17;
                    end

                    3'b011 : begin //MULHU
                        alucode = 8'd3;
                    end

                    3'b100 : begin //DIV
                        alucode = 8'd4;
                    end

                    3'b101 : begin //DIVU
                        alucode = 8'd12;
                    end

                    3'b110 : begin //REM
                        alucode = 8'd5;
                    end

                    3'b111 : begin //REMU
                        alucode = 8'd13;
                    end

                    endcase
                end

                else begin
                    case(funct3)
                    
                    3'b000 : begin //ADD/SUB
                        alucode = ((opcode == 7'b0110011) && funct7[5]) ? 8'd2 : 8'd1; //SUB  / ADD
                    end

                    3'b001 : begin //SLL
                        alucode = 8'd9;  //SLLI /SLL
                    end

                    3'b010 : begin //SLT
                        alucode = 8'd9; //SLTI / SLT
                    end

                    3'b011 : begin //SLTU 
                        alucode = 8'd9; //SLTUI / SLTU
                    end

                    3'b100 : begin //XOR
                        alucode = 8'd8; //XORI / XOR
                    end

                    3'b101 : begin //SRL/SRA
                        alucode = (funct7[5]) ? 8'd11 : 8'd10; //SRA / SRL ;  //SRAI SRLI / SRA SRL
                    end

                    3'b110 : begin //OR
                        alucode = 8'd7; //ORI / OR
                    end

                    3'b111 : begin //AND
                        alucode = 8'd6; //ANDI / AND
                    end

                    endcase
                end
            end
            
            7'b0110111,7'b0010111 : begin //U-TYPE 

                wr_en_rf = 1;
                alu_src_a = (opcode == 7'b0010111) ? 1 : 0; //AUIPC / LUI
                alu_src_b = 1;
                alucode = 8'd1;

            end

            7'b1100011 : begin //B-TYPE

                is_b_instr = 1;

            end

            7'b1101111, 7'b1100111 : begin //J-TYPE

                wr_en_rf = 1;
                is_jump = 1;
                is_j_instr = (opcode == 7'b1100111)  ? 1 : 0; //JALR / JAL 
                wb_sel = 2'b10;

            end

            7'b0100011 : begin //S-TYPE

                wr_en_mem = 1;
                alu_src_b = 1;
                alucode = 8'd1;

            end

            7'b0000011 : begin //LOAD

                wr_en_rf = 1;
                read_en_mem = 1;
                alu_src_b = 1;
                alucode = 8'd1;
                wb_sel = 2'b01;

            end

            7'b1110011 : begin
                wr_en_rf = 1;
                wr_en_mem = 0;
                read_en_mem = 0;

                case(funct3)

                    3'b000 : begin //TRAPS AND RETURNS
                        
                        case(csr_addr)

                        12'h000 : begin //ECALL
                            trap_take = 1;
                            is_jump = 1;
                            trap_cause = 32'h0000000B;
                        end

                        12'h001 : begin //EBREAK
                            trap_take = 1;
                            is_jump = 1;
                            trap_cause = 32'h00000003;
                        end

                        12'h302 : begin //MRET
                            mret_take = 1; 
                            is_jump = 1;
                        end

                        endcase

                    end

                    3'b001 : begin //CSRRW

                        csr_op = 2'b00;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;

                    end

                    3'b010 : begin //CSRRS

                        csr_op = 2'b01;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;

                    end

                    3'b011 : begin //CSSRC

                        csr_op = 2'b11;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;
                    end

                    3'b101 : begin //CSSRWI

                        csr_op = 2'b00;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;

                    end

                    3'b110 : begin //CSSRSI

                        csr_op = 2'b01;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;                        

                    end

                    3'b111 : begin //CSSRCI

                        csr_op = 2'b11;
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        wb_sel = 2'b11;

                    end

                endcase

            end

            7'b0001111 : begin //FENCE
                wr_en_rf = 0;
                wr_en_mem = 0;
                is_jump = 0;
            end

            default : begin
                wr_en_rf = 0;
                wr_en_mem = 0;
                is_jump =  0;
                alucode = 8'd0;
            end

            endcase

        end

    end
  
endmodule