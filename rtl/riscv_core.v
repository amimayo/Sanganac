module RISCV_CORE (
    input clk,
    input reset
);

    wire [31:0] pc_current, jump_pc, instr, imm_ext;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [31:0] rs1, rs2, rd;
    wire [63:0] alu_output;
    wire [31:0] alu_in1, alu_in2;
    wire [31:0] mem_addr, mem_read_data, mem_data_wr;
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;
    wire [7:0] aluop;
    wire [3:0] mem_mask;
    wire wr_en_rf, wr_en_mem, read_en_mem, is_jump;

    PC pc (
        .clk(clk),
        .reset(reset),
        .jump_pc(jump_pc),
        .is_jump(is_jump),
        .pc_next(pc_current)
    );

    REGFILE regfile (
        .clk(clk),
        .wr_en(wr_en_rf),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2)
    );

    INSTRMEM instrmem (
        .instr_addr(pc_current),
        .instr(instr)
    );

    DATAMEM datamem (
        .clk(clk),
        .addr(mem_addr),
        .mem_data_wr(mem_data_wr),
        .wr_en_mem(wr_en_mem),
        .read_en_mem(read_en_mem),
        .mem_mask(mem_mask),
        .mem_read_data(mem_read_data)
);  

    DECODER decoder (
        .instr(instr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .imm_ext(imm_ext)
    );

    ALU alu (
        .alucode(aluop),
        .rs1(alu_in1),
        .rs2(alu_in2),
        .rd(alu_output)
    );

    CONTROL_UNIT control_unit (
        .clk(clk),
        .reset(reset),

        .pc(pc_current),
        .mem_read(mem_read_data),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_output(alu_output),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .imm_ext(imm_ext),

        .alu_in1(alu_in1),
        .alu_in2(alu_in2),
        .out(rd), 
        .aluop(aluop),
        .wr_en_rf(wr_en_rf),
        .wr_en_mem(wr_en_mem),
        .read_en_mem(read_en_mem),
        .mem_data_wr(mem_data_wr),
        .mem_addr(mem_addr),
        .mem_mask(mem_mask),
        .jump_pc(jump_pc),
        .is_jump(is_jump)
    );
    
endmodule