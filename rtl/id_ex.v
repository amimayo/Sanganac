module ID_EX (
  input clk,
  input reset,
  input stall,
  input flush,

  input [31:0] pc_in,
  input [31:0] rs1_in,
  input [31:0] rs2_in,
  input [4:0] rs1_addr_in,
  input [4:0] rs2_addr_in,
  input [4:0] rd_addr_in,
  input [6:0] opcode_in,
  input [2:0] funct3_in,
  input [6:0] funct7_in,
  input [31:0] csr_data_in,
  input [31:0] imm_ext_in,
  input [7:0] alucode_in,
  input alu_src_a_in,
  input alu_src_b_in,
  input wr_en_rf_in,
  input wr_en_mem_in,
  input read_en_mem_in,
  input is_b_instr_in,
  input is_jump_in,
  input is_j_instr_in,
  input [1:0] wb_sel_in,

  output reg [31:0] pc_out,
  output reg [31:0] rs1_out,
  output reg [31:0] rs2_out,
  output reg [4:0] rs1_addr_out,
  output reg [4:0] rs2_addr_out,
  output reg [4:0] rd_addr_out,
  output reg [6:0] opcode_out,
  output reg [2:0] funct3_out,
  output reg [6:0] funct7_out,
  output reg [31:0] csr_data_out,
  output reg [31:0] imm_ext_out,
  output reg [7:0] alucode_out,
  output reg alu_src_a_out,
  output reg alu_src_b_out,
  output reg wr_en_rf_out,
  output reg wr_en_mem_out,
  output reg read_en_mem_out,
  output reg is_b_instr_out,
  output reg is_jump_out,
  output reg is_j_instr_out,
  output reg [1:0] wb_sel_out
);

    always @(posedge clk or posedge reset) begin

        if(reset || flush) begin

            pc_out <= 32'b0;
            rs1_out <= 32'b0;
            rs2_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            opcode_out <= 7'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            csr_data_out <= 32'b0;
            imm_ext_out <= 32'b0;
            alucode_out <= 8'b0;
            alu_src_a_out <= 1'b0;
            alu_src_b_out <= 1'b0;
            wr_en_rf_out <= 1'b0;
            wr_en_mem_out <= 1'b0;
            read_en_mem_out <= 1'b0;
            is_b_instr_out <= 1'b0;
            is_jump_out<= 1'b0;
            is_j_instr_out <= 1'b0;
            wb_sel_out <= 2'b0;

        end
        else if (stall) begin
          
        end
        else begin
        
            pc_out <= pc_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            opcode_out <= opcode_in ;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
            csr_data_out <= csr_data_in;
            imm_ext_out <= imm_ext_in;
            alucode_out <= alucode_in;
            alu_src_a_out <= alu_src_a_in;
            alu_src_b_out <= alu_src_b_in;
            wr_en_rf_out <= wr_en_rf_in;
            wr_en_mem_out <= wr_en_mem_in;
            read_en_mem_out <= read_en_mem_in;
            is_b_instr_out <= is_b_instr_in;
            is_jump_out<= is_jump_in;
            is_j_instr_out <= is_j_instr_in;
            wb_sel_out <= wb_sel_in;

        end
        
    end
    
endmodule