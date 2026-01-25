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


    reg [31:0] regfile [31:0];

    initial begin
        
        regfile[0] <= 0;
        regfile[1] <= 0;
        regfile[2] <= 0;
        regfile[3] <= 0;
        regfile[4] <= 0;
        regfile[5] <= 0;
        regfile[6] <= 0;
        regfile[7] <= 0;
        regfile[8] <= 0;
        regfile[9] <= 0;
        regfile[10] <= 0;
        regfile[11] <= 0;
        regfile[12] <= 0;
        regfile[13] <= 0;
        regfile[14] <= 0;
        regfile[15] <= 0;
        regfile[16] <= 0;
        regfile[17] <= 0;
        regfile[18] <= 0;
        regfile[19] <= 0;
        regfile[20] <= 0;
        regfile[21] <= 0;
        regfile[22] <= 0;
        regfile[23] <= 0;
        regfile[24] <= 0;
        regfile[25] <= 0;
        regfile[26] <= 0;
        regfile[27] <= 0;
        regfile[28] <= 0;
        regfile[29] <= 0;
        regfile[30] <= 0;
        regfile[31] <= 0;

    end

    assign rs1 = regfile[rs1_addr];
    assign rs2 = regfile[rs2_addr];   

    always @(posedge clk) begin
        regfile[0] <= 0;

        if (wr_en && rd_addr != 5'd0) begin
            regfile[rd_addr] <= rd;
        end
    end

endmodule