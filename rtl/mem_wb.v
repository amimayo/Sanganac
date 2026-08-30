module MEM_WB (
    input clk,
    input reset,

    input [31:0] pc_in,
    input wr_en_rf_in,
    input [1:0] wb_sel_in,
    input [4:0] rd_addr_in,
    input [31:0] ex_result_in,
    input [31:0] mem_read_data_in,
    input [31:0] csr_data_in,

    output reg wr_en_rf_out,
    output reg [4:0] rd_addr_out,
    output reg [31:0] wb_data_out

);

    reg wr_en_rf_r;
    reg [1:0] wb_sel_r;
    reg [4:0] rd_addr_r;
    reg [31:0] ex_result_r;
    reg [31:0] mem_read_data_r;
    reg [31:0] mem_wb_pc_r;
    reg [31:0] csr_data_r;

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin

            wr_en_rf_r <= 1'b0;
            wb_sel_r <= 1'b0;
            rd_addr_r <= 5'b0;
            ex_result_r <= 32'b0;
            mem_read_data_r <= 32'b0;
            mem_wb_pc_r <= 32'b0;
            csr_data_r <= 32'b0;

        end
        else begin
          
            wr_en_rf_r <= wr_en_rf_in;
            wb_sel_r <= wb_sel_in;
            rd_addr_r <= rd_addr_in;
            ex_result_r <= ex_result_in;
            mem_read_data_r <= mem_read_data_in;
            mem_wb_pc_r <= pc_in;
            csr_data_r <= csr_data_in;

        end

    end

    always @(*) begin

        wr_en_rf_out = wr_en_rf_r;
        rd_addr_out = rd_addr_r;

        case (wb_sel_r)

            2'b00 : wb_data_out = ex_result_r; // ALU
            2'b01 : wb_data_out = mem_read_data_r; // MEM
            2'b10 : wb_data_out = mem_wb_pc_r + 32'd4; // JUMP
            2'b11 : wb_data_out = csr_data_r; // CSR
            default : wb_data_out = ex_result_r;

        endcase
        
    end
    
endmodule