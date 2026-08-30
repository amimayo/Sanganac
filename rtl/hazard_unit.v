module HAZARD_UNIT (
    
    input [4:0] id_rs1_addr,
    input [4:0] id_rs2_addr,
    input [4:0] id_ex_rd_addr,
    input id_ex_read_en_mem,
    input [4:0] ex_rs1_addr,
    input [4:0] ex_rs2_addr,
    input [4:0] ex_mem_rd_addr,
    input ex_mem_wr_en_rf,
    input [4:0] mem_wb_rd_addr,
    input mem_wb_wr_en_rf,

    output reg pc_stall,
    output reg if_id_stall,
    output reg id_ex_flush,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b

);

    localparam NO = 2'b00;
    localparam MEM_WB = 2'b01;
    localparam EX_MEM = 2'b10;

    wire load_use_hazard;

    assign load_use_hazard = (id_ex_read_en_mem) && ((id_ex_rd_addr != 5'b0) && 
    ((id_ex_rd_addr == id_rs1_addr) || (id_ex_rd_addr == id_rs2_addr)));

    always @(*) begin

        pc_stall = load_use_hazard;
        if_id_stall = load_use_hazard;
        id_ex_flush = load_use_hazard;
        
    end

    always @(*) begin

        if ((ex_mem_wr_en_rf)  && (ex_mem_rd_addr != 5'b0) && (ex_mem_rd_addr == ex_rs1_addr)) begin
          
            forward_a = EX_MEM;

        end
        else if ((mem_wb_wr_en_rf)  && (mem_wb_rd_addr != 5'b0) && (mem_wb_rd_addr == ex_rs1_addr)) begin
          
            forward_a = MEM_WB;

        end
        else begin
          
            forward_a = NO;

        end
        
    end

    always @(*) begin

        if ((ex_mem_wr_en_rf)  && (ex_mem_rd_addr != 5'b0) && (ex_mem_rd_addr == ex_rs2_addr)) begin
          
            forward_b = EX_MEM;

        end
        else if ((mem_wb_wr_en_rf)  && (mem_wb_rd_addr != 5'b0) && (mem_wb_rd_addr == ex_rs2_addr)) begin
          
            forward_b = MEM_WB;

        end
        else begin
          
            forward_b = NO;

        end
        
    end



endmodule