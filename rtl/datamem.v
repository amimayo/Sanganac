module DATAMEM (
    input clk,
    input [31:0] addr,
    input [31:0] mem_data_wr,
    input wr_en_mem,
    input read_en_mem,
    input [2:0] funct3,
    output reg [31:0] mem_read_data
);

    reg [31:0] datamem [0:2047];
    wire [10:0] word_addr = addr[12:2];
    wire [1:0] byte_sel = addr[1:0];
    wire load_unsigned;
    reg [3:0] mem_mask;
    
    assign load_unsigned = funct3[2];

    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            datamem[i] = 32'h0;
        end 

        `ifdef COCOTB_SIM

            $readmemh("../data_mem.hex", datamem);

        `else 

            $readmemh("./data_mem.hex", datamem);

        `endif

    end

    always @(*) begin

        mem_mask = 4'b0000;

        if (wr_en_mem || read_en_mem) begin
            
            case (funct3[1:0])

                2'b00 : begin // LB, LBU, SB
                    case (byte_sel)
                        2'b00 : mem_mask = 4'b0001;
                        2'b01 : mem_mask = 4'b0010;
                        2'b10 : mem_mask = 4'b0100;
                        2'b11 : mem_mask = 4'b1000;
                    endcase
                end

                2'b01 : mem_mask =  (byte_sel[1]) ? 4'b1100 : 4'b0011; // LH, LHU, SH

                2'b10 : mem_mask = 4'b1111;  // LW, SW

                default : mem_mask = 4'b0000;

            endcase


        end
        
    end

    always @(*) begin

        if(read_en_mem) begin //Data Memory Read

            case(mem_mask)

            4'b0001 : mem_read_data = (load_unsigned) ? {24'b0, datamem[word_addr][7:0]} : {{24{datamem[word_addr][7]}}, datamem[word_addr][7:0] };
            4'b0010 : mem_read_data = (load_unsigned) ? {24'b0, datamem[word_addr][15:8]} : {{24{datamem[word_addr][15]}}, datamem[word_addr][15:8] };
            4'b0100 : mem_read_data = (load_unsigned) ? {24'b0, datamem[word_addr][23:16]} : {{24{datamem[word_addr][23]}}, datamem[word_addr][23:16] };
            4'b1000 : mem_read_data = (load_unsigned) ? {24'b0, datamem[word_addr][31:24]} : {{24{datamem[word_addr][31]}}, datamem[word_addr][31:24] };
            4'b0011 : mem_read_data = (load_unsigned) ? {16'b0, datamem[word_addr][15:0]} : {{16{datamem[word_addr][15]}}, datamem[word_addr][15:0] };
            4'b1100 : mem_read_data = (load_unsigned) ? {16'b0, datamem[word_addr][31:16]} : {{16{datamem[word_addr][31]}}, datamem[word_addr][31:16] };
            4'b1111 : mem_read_data = datamem[word_addr];
            default : mem_read_data = datamem[word_addr];

            endcase

        end
        else begin 
            mem_read_data = 32'b0;
        end
    end

    always @(posedge clk) begin
        
        if(wr_en_mem) begin //Data Memory Write

            if(mem_mask[0]) datamem[word_addr][7:0] <= mem_data_wr[7:0];
            if(mem_mask[1]) datamem[word_addr][15:8] <= mem_data_wr[15:8];
            if(mem_mask[2]) datamem[word_addr][23:16] <= mem_data_wr[23:16];
            if(mem_mask[3]) datamem[word_addr][31:24] <= mem_data_wr[31:24];

        end

    end

endmodule