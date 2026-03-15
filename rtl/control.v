module CONTROL_UNIT (
    input clk,
    input reset,

    input [31:0] pc,
    input [31:0] mem_read,
    input [4:0] csr_imm,
    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [63:0] rd_output,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm_ext,
    input [31:0] trap_pc,
    input [31:0] mret_pc,
    input [31:0] csr_read_data,
    input mie_out,
    input ext_int,

    output reg [31:0] alu_in1,
    output reg [31:0] alu_in2,
    output reg [31:0] out, 
    output reg [7:0] aluop,
    output reg wr_en_rf,
    output reg wr_en_mem,
    output reg read_en_mem,
    output reg load_unsigned,
    output reg [31:0] mem_data_wr,
    output reg [31:0] mem_addr,
    output reg [3:0] mem_mask,
    output reg [31:0] jump_pc,
    output reg is_jump,

    output reg [1:0] csr_op,
    output reg [11:0] csr_addr,
    output reg [31:0] csr_wr_data,
    output reg csr_wr_en,
    output reg csr_read_en,
    output reg trap_take,
    output reg mret_take,
    output reg [31:0] trap_cause
);

    wire [1:0] byte_sel;
    assign byte_sel = rd_output[1:0]; 

    always @(*) begin
        
        alu_in1     = rs1_in;
        alu_in2     = rs2_in;
        out         = 32'b0; 
        aluop       = 8'd0;
        wr_en_rf    = 0;
        wr_en_mem   = 0;
        read_en_mem = 0;
        load_unsigned = 0;
        mem_data_wr = rs2_in;
        mem_addr    = rd_output[31:0];
        mem_mask    = 4'b0000;
        jump_pc     = pc + imm_ext;
        is_jump     = 0;
        csr_addr = imm_ext[11:0];
        csr_wr_en = 0;
        csr_read_en = 0;
        trap_take = 0;
        mret_take = 0;

        if (ext_int & mie_out) begin  //INTERRUPT
            trap_take = 1;
            jump_pc = trap_pc;
            is_jump = 1;
            trap_cause = 32'h8000000B; //MEI
        end

        else begin

            case(opcode)

            7'b0110011,7'b0010011 : begin //R-TYPE / I-TYPE
                wr_en_rf = 1;

                if ((opcode == 7'b0110011) && (funct7 == 7'b0000001)) begin //M-TYPE
                    case(funct3)

                    3'b000 : begin //MUL
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd3;
                        out = rd_output[31:0];
                    end
    
                    3'b001 : begin //MULH
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd16;
                        out = rd_output[63:32];
                    end

                    3'b010 : begin //MULHSU
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd17;
                        out = rd_output[63:32];
                    end

                    3'b011 : begin //MULHU
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd3;
                        out = rd_output[63:32];
                    end

                    3'b100 : begin //DIV
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd4;
                        out = rd_output;
                    end

                    3'b101 : begin //DIVU
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd12;
                        out = rd_output;
                    end

                    3'b110 : begin //REM
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd5;
                        out = rd_output;
                    end

                    3'b111 : begin //REMU
                        alu_in1 = rs1_in;
                        alu_in2 = rs2_in;
                        aluop = 8'd13;
                        out = rd_output;
                    end

                    endcase
                end

                else begin
                    case(funct3)
                    
                    3'b000 : begin //ADD/SUB
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //IMM FOR I-TYPE : RS2 FOR R-TYPE
                        aluop = ((opcode == 7'b0110011) && funct7[5]) ? 8'd2 : 8'd1; //SUB  / ADD
                        out = rd_output;
                    end

                    3'b001 : begin //SLL
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //SLLI /S LL
                        aluop = 8'd9;
                        out = rd_output;
                    end

                    3'b010 : begin //SLT
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //SLTI / SLT
                        aluop = 8'd9;
                        out = rd_output;
                    end

                    3'b011 : begin //SLTU
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //SLTUI / SLTU
                        aluop = 8'd9;
                        out = rd_output;
                    end

                    3'b100 : begin //XOR
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in ; //XORI / XOR
                        aluop = 8'd8;
                        out = rd_output;
                    end

                    3'b101 : begin //SRL/SRA
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //SRAI SRLI / SRA SRL
                        aluop = (funct7[5]) ? 8'd11 : 8'd10; //SRA / SRL
                        out = rd_output;
                    end

                    3'b110 : begin //OR
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //ORI / OR
                        aluop = 8'd7;
                        out = rd_output;
                    end

                    3'b111 : begin //AND
                        alu_in1 = rs1_in;
                        alu_in2 = (opcode == 7'b0010011) ? imm_ext : rs2_in; //ANDI / AND
                        aluop = 8'd6;
                        out = rd_output;
                    end

                    endcase
                end
            end
            
            7'b0110111,7'b0010111 : begin //U-TYPE 
                wr_en_rf = 1;

                aluop = 0;
                out = (opcode == 7'b0110111) ? imm_ext : pc + imm_ext; //LUI / AUIPC
            end

            7'b1100011 : begin //B-TYPE
                
                case(funct3)
                
                3'b000 : begin //BEQ
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd2;
                    jump_pc = pc + imm_ext;
                    is_jump = (rs1_in == rs2_in);           
                end

                3'b001 : begin //BNE
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd2;
                    jump_pc = pc + imm_ext;
                    is_jump = (rs1_in != rs2_in);           
                end

                3'b100 : begin //BLT
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd14;
                    jump_pc = pc + imm_ext;
                    is_jump = ($signed(rs1_in) < $signed(rs2_in));           
                end

                3'b101 : begin //BGE
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd2;
                    jump_pc = pc + imm_ext;
                    is_jump = ($signed(rs1_in) >= $signed(rs2_in));           
                end

                3'b110 : begin //BLTU
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd15;
                    jump_pc = pc + imm_ext;
                    is_jump = (rs1_in < rs2_in);           
                end

                3'b111 : begin //BGEU
                    alu_in1 = rs1_in;
                    alu_in2 = rs2_in;
                    aluop = 8'd2;
                    jump_pc = pc + imm_ext;
                    is_jump = (rs1_in >= rs2_in);           
                end

                endcase
            end

            7'b1101111, 7'b1100111 : begin //J-TYPE
                wr_en_rf = 1;
                is_jump = 1;
                jump_pc = (opcode == 7'b1101111) ? pc + imm_ext : (rs1_in + imm_ext) & ~32'd1; //JAL / JALR
                out = pc + 4;
            end

            7'b0100011 : begin //S-TYPE
                wr_en_mem = 1;
                
                alu_in1 = rs1_in;
                alu_in2 = imm_ext;
                aluop = 8'd1;
                mem_data_wr = rs2_in;
                mem_addr = rd_output[31:0];

                case(funct3)

                3'b000 : begin //SB
                    case(byte_sel)

                    2'b00 : mem_mask = 4'b0001;
                    2'b01 : mem_mask = 4'b0010;
                    2'b10 : mem_mask = 4'b0100;
                    2'b11 : mem_mask = 4'b1000;

                    endcase
                end 

                3'b001 : mem_mask = (byte_sel[1]) ? 4'b1100 : 4'b0011; //SH

                3'b010 : mem_mask = 4'b1111; ///SW

                endcase
            end

            7'b0000011 : begin //LOAD
                wr_en_rf = 1;
                read_en_mem = 1;
                alu_in1 = rs1_in;
                alu_in2 = imm_ext;
                aluop = 8'd1;
                mem_addr = rd_output[31:0];
                out = mem_read;

                case(funct3)

                3'b000 : begin //LB
                    case(byte_sel)

                    2'b00 : mem_mask = 4'b0001;
                    2'b01 : mem_mask = 4'b0010;
                    2'b10 : mem_mask = 4'b0100;
                    2'b11 : mem_mask = 4'b1000;

                    endcase
                end 

                3'b001 : mem_mask = (byte_sel[1]) ? 4'b1100 : 4'b0011; //LH

                3'b010 : mem_mask = 4'b1111; ///LW

                3'b100 : begin //LBU

                    load_unsigned = 1;

                    case(byte_sel)

                    2'b00 : mem_mask = 4'b0001;
                    2'b01 : mem_mask = 4'b0010;
                    2'b10 : mem_mask = 4'b0100;
                    2'b11 : mem_mask = 4'b1000;

                    endcase
                end

                3'b101 : begin //LHU

                    load_unsigned = 1;
                    
                    mem_mask = (byte_sel[1]) ? 4'b1100 : 4'b0011;

                end

                endcase
            end

            7'b1110011 : begin
                wr_en_rf = 1;
                wr_en_mem = 0;
                read_en_mem = 0;
                out = csr_read_data;

                case(funct3)

                    3'b000 : begin //TRAPS AND RETURNS
                        
                        case(imm_ext[11:0])

                        12'h000 : begin //ECALL
                            trap_take = 1;
                            jump_pc = trap_pc;
                            is_jump = 1;
                            trap_cause = 32'h0000000B;
                        end

                        12'h001 : begin //EBREAK
                            trap_take = 1;
                            jump_pc = trap_pc;
                            is_jump = 1;
                            trap_cause = 32'h00000003;
                        end

                        12'h302 : begin //MRET
                            mret_take = 1;  
                            jump_pc = mret_pc;
                            is_jump = 1;
                        end

                        endcase

                    end

                    3'b001 : begin //CSRRW

                        csr_op = 2'b00;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = rs1_in;

                    end

                    3'b010 : begin //CSRRS

                        csr_op = 2'b01;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = rs1_in;

                    end

                    3'b011 : begin //CSSRC

                        csr_op = 2'b11;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = rs1_in;

                    end

                    3'b101 : begin //CSSRWI

                        csr_op = 2'b00;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = {27'b0, csr_imm};

                    end

                    3'b110 : begin //CSSRSI

                        csr_op = 2'b01;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = {27'b0, csr_imm};

                    end

                    3'b111 : begin //CSSRCI

                        csr_op = 2'b11;
                        csr_addr = imm_ext[11:0];
                        csr_wr_en = 1;
                        csr_read_en = 1;
                        csr_wr_data = {27'b0, csr_imm};

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
                aluop = 8'd0;
            end

            endcase

        end

    end
  
endmodule