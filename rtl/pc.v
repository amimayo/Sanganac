module PC (
    input clk,
    input reset,
    input [31:0] jump_pc,
    input is_jump,
    output [31:0] pc_next
);

    reg [31:0] pc;

    always @(posedge clk) begin
        
        if (reset) begin
            pc <= 0;
        end
        else if (is_jump) begin
            pc <= jump_pc;
        end
        else begin
            pc <= pc + 32'd4;
        end
    
    end

    assign pc_next = pc;
    
endmodule