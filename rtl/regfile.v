module REGFILE (
    input clk,
    input wr_en,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,
    input [31:0] rd,
    output wire [31:0] rs1,
    output wire [31:0] rs2
);


    reg [31:0] registerfile [31:0];

    initial begin
        
        registerfile[0] <= 0;
        registerfile[1] <= 0;
        registerfile[2] <= 0;
        registerfile[3] <= 0;
        registerfile[4] <= 0;
        registerfile[5] <= 0;
        registerfile[6] <= 0;
        registerfile[7] <= 0;
        registerfile[8] <= 0;
        registerfile[9] <= 0;
        registerfile[10] <= 0;
        registerfile[11] <= 0;
        registerfile[12] <= 0;
        registerfile[13] <= 0;
        registerfile[14] <= 0;
        registerfile[15] <= 0;
        registerfile[16] <= 0;
        registerfile[17] <= 0;
        registerfile[18] <= 0;
        registerfile[19] <= 0;
        registerfile[20] <= 0;
        registerfile[21] <= 0;
        registerfile[22] <= 0;
        registerfile[23] <= 0;
        registerfile[24] <= 0;
        registerfile[25] <= 0;
        registerfile[26] <= 0;
        registerfile[27] <= 0;
        registerfile[28] <= 0;
        registerfile[29] <= 0;
        registerfile[30] <= 0;
        registerfile[31] <= 0;

    end

    assign rs1 = registerfile[rs1_addr];
    assign rs2 = registerfile[rs2_addr];   

    always @(posedge clk) begin
        registerfile[0] <= 0;

        if (wr_en && rd_addr != 5'd0) begin
            registerfile[rd_addr] <= rd;
        end
    end

endmodule