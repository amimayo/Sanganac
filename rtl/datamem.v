module DATAMEM (
    input clk,
    input [31:0] addr,
    input [31:0] mem_data_wr,
    input wr_en_mem,
    input read_en_mem,
    input [3:0] mem_mask,
    output reg [31:0] mem_read_data
);

    reg [31:0] datamem [0:2047];
    wire [10:0] word_addr = addr[12:2];
    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            datamem[i] = 32'h0;
        end 
        $readmemh("./sim/data_mem.hex", datamem);
    end

    always @(*) begin

        if(read_en_mem) begin

            case(mem_mask)

            4'b0001 : mem_read_data = {{24{datamem[word_addr][7]}}, datamem[word_addr][7:0] };
            4'b0010 : mem_read_data = {{24{datamem[word_addr][15]}}, datamem[word_addr][15:8] };
            4'b0100 : mem_read_data = {{24{datamem[word_addr][23]}}, datamem[word_addr][23:16] };
            4'b1000 : mem_read_data = {{24{datamem[word_addr][31]}}, datamem[word_addr][31:24] };
            4'b0011 : mem_read_data = {{16{datamem[word_addr][15]}}, datamem[word_addr][15:0] };
            4'b1100 : mem_read_data = {{16{datamem[word_addr][31]}}, datamem[word_addr][31:16] };
            4'b1111 : mem_read_data = datamem[word_addr];
            default : mem_read_data = datamem[word_addr];

            endcase

        end
        else begin 
            mem_read_data = 32'b0;
        end
    end

    always @(posedge clk) begin
        
        if(wr_en_mem) begin

            if(mem_mask[0]) datamem[word_addr][7:0] <= mem_data_wr[7:0];
            if(mem_mask[1]) datamem[word_addr][15:8] <= mem_data_wr[15:8];
            if(mem_mask[2]) datamem[word_addr][23:16] <= mem_data_wr[23:16];
            if(mem_mask[3]) datamem[word_addr][31:24] <= mem_data_wr[31:24];

        end

    end

endmodule