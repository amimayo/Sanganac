module IF_ID(
    input clk,
    input reset,
    input flush,
    input stall,

    input [31:0] pc_in,
    input [31:0] instr_in,

    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);

    always @(posedge clk or posedge reset) begin
        
        if (reset || flush) begin
            pc_out <= 32'd0;
            instr_out <= 32'b0;
        end
        else if (stall) begin
            
        end
        else begin
          pc_out <= pc_in;
          instr_out <= instr_in;
        end


    end

endmodule