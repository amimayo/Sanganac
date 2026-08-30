module RISCV_CORE (
    input clk,
    input reset
);

    // FETCH

    wire [31:0] if_pc, if_instr, ex_jump_pc;
    wire pc_stall, if_id_stall, ex_branch_taken, id_ex_flush_hazard;

    wire is_jump = id_trap_take || id_mret_take || ex_branch_taken;

    wire [31:0] jump_pc = id_trap_take ? trap_pc : (id_mret_take ? mret_pc : ex_jump_pc);

    PC pc (
        .clk(clk),
        .reset(reset),
        .jump_pc(jump_pc),
        .stall(pc_stall),
        .is_jump(is_jump),
        .pc_next(if_pc)
    );

    INSTRMEM instrmem (
        .instr_addr(if_pc),
        .instr(if_instr)
    );

    wire [31:0] if_id_pc, if_id_instr;
    
    wire if_id_flush = ex_branch_taken || id_trap_take || id_mret_take; 

    IF_ID if_id (
        .clk(clk),
        .reset(reset),
        .flush(if_id_flush),
        .stall(if_id_stall),
        .pc_in(if_pc),
        .instr_in(if_instr),

        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    // DECODE

    wire [4:0] id_rs1_addr, id_rs2_addr, id_rd_addr;
    wire [6:0] id_opcode, id_funct7;
    wire [2:0] id_funct3;
    wire [31:0] id_imm_ext, id_rs1, id_rs2;

    DECODER decoder (
        .instr(if_id_instr),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(id_rd_addr),
        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .imm_ext(id_imm_ext)
    );

    wire [7:0] id_alucode;
    wire id_alu_src_a, id_alu_src_b;
    wire id_wr_en_rf, id_wr_en_mem, id_read_en_mem;
    wire id_is_b_instr, id_is_jump, id_is_j_instr;
    wire [1:0] id_wb_sel, id_csr_op;
    wire id_csr_wr_en, id_csr_read_en, id_trap_take, id_mret_take;
    wire [31:0] id_trap_cause, csr_read_data, trap_pc, mret_pc;
    wire mie_out;

    CONTROL_UNIT control_unit (
        .clk(clk),
        .reset(reset),

        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .csr_addr(if_id_instr[31:20]),
        .mie_out(mie_out),
        .ext_int(1'b0),

        .alucode(id_alucode),
        .alu_src_a(id_alu_src_a),
        .alu_src_b(id_alu_src_b),
        .wr_en_rf(id_wr_en_rf),
        .wr_en_mem(id_wr_en_mem),
        .read_en_mem(id_read_en_mem),
        .is_b_instr(id_is_b_instr),
        .is_jump(id_is_jump),
        .is_j_instr(id_is_j_instr),
        .wb_sel(id_wb_sel),

        .csr_op(id_csr_op),
        .csr_wr_en(id_csr_wr_en),
        .csr_read_en(id_csr_read_en),
        .trap_take(id_trap_take),
        .mret_take(id_mret_take),
        .trap_cause(id_trap_cause)
    );

    wire [31:0] id_ex_pc, id_ex_rs1, id_ex_rs2;
    wire [4:0] id_ex_rs1_addr, id_ex_rs2_addr, id_ex_rd_addr;
    wire [6:0] id_ex_opcode, id_ex_funct7;
    wire [7:0] id_ex_alucode;
    wire [2:0] id_ex_funct3;
    wire [31:0] id_ex_csr_data, id_ex_imm_ext;
    wire id_ex_alu_src_a, id_ex_alu_src_b;
    wire id_ex_wr_en_rf, id_ex_wr_en_mem, id_ex_read_en_mem;
    wire id_ex_is_b_instr, id_ex_is_jump, id_ex_is_j_instr;
    wire [1:0] id_ex_wb_sel;

    wire id_ex_flush = id_ex_flush_hazard || ex_branch_taken || id_trap_take || id_mret_take;

    ID_EX id_ex (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(id_ex_flush),

        .pc_in(if_id_pc),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rs1_addr_in(id_rs1_addr),
        .rs2_addr_in(id_rs2_addr),
        .rd_addr_in(id_rd_addr),
        .opcode_in(id_opcode),
        .funct3_in(id_funct3),
        .funct7_in(id_funct7),
        .csr_data_in(csr_read_data),
        .imm_ext_in(id_imm_ext),
        .alucode_in(id_alucode),
        .alu_src_a_in(id_alu_src_a),
        .alu_src_b_in(id_alu_src_b),
        .wr_en_rf_in(id_wr_en_rf),
        .wr_en_mem_in(id_wr_en_mem),
        .read_en_mem_in(id_read_en_mem),
        .is_b_instr_in(id_is_b_instr),
        .is_jump_in(id_is_jump),
        .is_j_instr_in(id_is_j_instr),
        .wb_sel_in(id_wb_sel),

        .pc_out(id_ex_pc),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_addr_out(id_ex_rd_addr),
        .rs1_addr_out(id_ex_rs1_addr),
        .rs2_addr_out(id_ex_rs2_addr),
        .opcode_out(id_ex_opcode),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7),
        .csr_data_out(id_ex_csr_data),
        .imm_ext_out(id_ex_imm_ext),
        .alucode_out(id_ex_alucode),
        .alu_src_a_out(id_ex_alu_src_a),
        .alu_src_b_out(id_ex_alu_src_b),
        .wr_en_rf_out(id_ex_wr_en_rf),
        .wr_en_mem_out(id_ex_wr_en_mem),
        .read_en_mem_out(id_ex_read_en_mem),
        .is_b_instr_out(id_ex_is_b_instr),
        .is_jump_out(id_ex_is_jump),
        .is_j_instr_out(id_ex_is_j_instr),
        .wb_sel_out(id_ex_wb_sel)
    );

    // EXECUTE

    wire [1:0] forward_a, forward_b;
    wire [31:0] ex_mem_alu_result, mem_wb_wb_data;
    wire [63:0] ex_alu_result;
    wire [31:0] ex_mem_data_wr;
    
    EXECUTE execute (
        .pc(id_ex_pc),
        .rs1_data(id_ex_rs1),
        .rs2_data(id_ex_rs2),
        .imm_ext(id_ex_imm_ext),
        .opcode(id_ex_opcode),
        .funct3(id_ex_funct3),
        .alucode(id_ex_alucode),
        .alu_src_a(id_ex_alu_src_a),
        .alu_src_b(id_ex_alu_src_b),
        .is_b_instr(id_ex_is_b_instr),
        .is_jump(id_ex_is_jump),
        .is_j_instr(id_ex_is_j_instr),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_wr_data(mem_wb_wb_data),

        .alu_result(ex_alu_result),
        .mem_data_wr(ex_mem_data_wr),
        .branch_taken(ex_branch_taken),
        .jump_pc(ex_jump_pc)
    );

    wire ex_mem_wr_en_rf, ex_mem_wr_en_mem, ex_mem_read_en_mem;
    wire [4:0] ex_mem_rd_addr;
    wire [1:0] ex_mem_wb_sel;
    wire [31:0] ex_mem_mem_data_wr, ex_mem_csr_data, ex_mem_pc;
    wire [2:0] ex_mem_funct3;

    EX_MEM ex_mem (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),

        .pc_in(id_ex_pc),
        .wr_en_rf_in(id_ex_wr_en_rf),
        .wr_en_mem_in(id_ex_wr_en_mem),
        .read_en_mem_in(id_ex_read_en_mem),
        .rd_addr_in(id_ex_rd_addr),
        .wb_sel_in(id_ex_wb_sel),
        .ex_result_in(ex_alu_result[31:0]),
        .mem_data_wr_in(ex_mem_data_wr),
        .csr_data_in(id_ex_csr_data),
        .funct3_in(id_ex_funct3),

        .pc_out(ex_mem_pc),
        .wr_en_rf_out(ex_mem_wr_en_rf),
        .wr_en_mem_out(ex_mem_wr_en_mem),
        .read_en_mem_out(ex_mem_read_en_mem),
        .rd_addr_out(ex_mem_rd_addr),
        .wb_sel_out(ex_mem_wb_sel),
        .ex_result_out(ex_mem_alu_result),
        .mem_data_wr_out(ex_mem_mem_data_wr),
        .csr_data_out(ex_mem_csr_data),
        .funct3_out(ex_mem_funct3)
    );

    // MEMORY ACCESS

    wire [31:0] mem_read_data;

    DATAMEM datamem (
        .clk(clk),
        .addr(ex_mem_alu_result),
        .mem_data_wr(ex_mem_mem_data_wr),
        .wr_en_mem(ex_mem_wr_en_mem),
        .read_en_mem(ex_mem_read_en_mem),
        .funct3(ex_mem_funct3),
        .mem_read_data(mem_read_data)
    );

    wire mem_wb_wr_en_rf;
    wire [4:0] mem_wb_rd_addr;

    MEM_WB mem_wb (
        .clk(clk),
        .reset(reset),

        .pc_in(ex_mem_pc),
        .wr_en_rf_in(ex_mem_wr_en_rf),
        .wb_sel_in(ex_mem_wb_sel),
        .rd_addr_in(ex_mem_rd_addr),
        .ex_result_in(ex_mem_alu_result),
        .mem_read_data_in(mem_read_data),
        .csr_data_in(ex_mem_csr_data),

        .wr_en_rf_out(mem_wb_wr_en_rf),
        .rd_addr_out(mem_wb_rd_addr),
        .wb_data_out(mem_wb_wb_data)
    );

    // WRITEBACK 

    REGFILE regfile (
        .clk(clk),
        .wr_en(mem_wb_wr_en_rf),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(mem_wb_rd_addr),
        .rd(mem_wb_wb_data),
        .rs1(id_rs1),
        .rs2(id_rs2)
    );

    HAZARD_UNIT hazard_unit (
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_read_en_mem(id_ex_read_en_mem),
        .ex_rs1_addr(id_ex_rs1_addr),
        .ex_rs2_addr(id_ex_rs2_addr),
        .ex_mem_rd_addr(ex_mem_rd_addr),
        .ex_mem_wr_en_rf(ex_mem_wr_en_rf),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .mem_wb_wr_en_rf(mem_wb_wr_en_rf),

        .pc_stall(pc_stall),
        .if_id_stall(if_id_stall),
        .id_ex_flush(id_ex_flush_hazard),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire is_csr_imm = (id_opcode == 7'b1110011) && id_funct3[2];

    wire [31:0] forwarded_csr_rs1 = 
        (id_ex_wr_en_rf && (id_ex_rd_addr != 5'b0) && (id_ex_rd_addr == id_rs1_addr)) ? ex_alu_result[31:0] :
        (ex_mem_wr_en_rf && (ex_mem_rd_addr != 5'b0) && (ex_mem_rd_addr == id_rs1_addr)) ? ex_mem_alu_result :
        (mem_wb_wr_en_rf && (mem_wb_rd_addr != 5'b0) && (mem_wb_rd_addr == id_rs1_addr)) ? mem_wb_wb_data : 
        id_rs1;

    wire [31:0] csr_wr_data = is_csr_imm ? {27'b0, id_rs1_addr} : forwarded_csr_rs1;

    CSR csr (
        .clk(clk),
        .reset(reset),
        .pc(if_id_pc),
        .csr_op(id_csr_op),
        .csr_addr(if_id_instr[31:20]),
        .csr_wr_data(csr_wr_data),
        .csr_wr_en(id_csr_wr_en),
        .csr_read_en(id_csr_read_en),
        .trap_take(id_trap_take),
        .mret_take(id_mret_take),
        .trap_cause(id_trap_cause),
        .csr_read_data(csr_read_data),
        .trap_pc(trap_pc),
        .mret_pc(mret_pc),
        .mie_out(mie_out)
    );



endmodule