module EX_MEM (
    input clk,
    input reset,
    input stall,

    input [31:0] pc_in,
    input wr_en_rf_in,
    input wr_en_mem_in,
    input read_en_mem_in,
    input [4:0] rd_addr_in,
    input [1:0] wb_sel_in,
    input [31:0] ex_result_in,
    input [31:0] mem_data_wr_in,
    input [31:0] csr_data_in,
    input [2:0] funct3_in,

    output reg [31:0] pc_out,
    output reg wr_en_rf_out,
    output reg wr_en_mem_out,
    output reg read_en_mem_out,
    output reg [4:0] rd_addr_out,
    output reg [1:0] wb_sel_out,
    output reg [31:0] ex_result_out,
    output reg [31:0] mem_data_wr_out,
    output reg [31:0] csr_data_out,
    output reg [2:0] funct3_out

);

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin

            pc_out <= 32'b0;
            wr_en_rf_out <= 1'b0;
            wr_en_mem_out <= 1'b0;
            read_en_mem_out <= 1'b0;
            rd_addr_out <= 5'b0;
            wb_sel_out <= 2'b0;
            ex_result_out <= 32'b0;
            mem_data_wr_out <= 32'b0;
            csr_data_out <= 32'b0;
            funct3_out <= 3'b0;

        end
        else if (!stall) begin
            
            pc_out <= pc_in;
            wr_en_rf_out <= wr_en_rf_in;
            wr_en_mem_out <= wr_en_mem_in;
            read_en_mem_out <= read_en_mem_in;
            rd_addr_out <= rd_addr_in;
            wb_sel_out <= wb_sel_in;
            ex_result_out <= ex_result_in;
            mem_data_wr_out <= mem_data_wr_in;
            csr_data_out <= csr_data_in;
            funct3_out <= funct3_in;

        end

    end

endmodule