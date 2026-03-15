module CSR (
    input clk,
    input reset,

    input [31:0] pc,
    input [1:0] csr_op,
    input [11:0] csr_addr,
    input [31:0] csr_wr_data,
    input csr_wr_en,
    input csr_read_en,

    input trap_take,
    input mret_take,
    input [31:0] trap_cause,
    
    output reg [31:0] csr_read_data,
    output reg [31:0] trap_pc,
    output reg [31:0] mret_pc,
    output reg mie_out   
);

reg [31:0] mstatus, mtvec, mepc, mcause;

localparam MSTATUS = 12'h300;
localparam MTVEC = 12'h305;
localparam MEPC = 12'h341;
localparam MCAUSE = 12'h342;

    always @(*) begin
        
        trap_pc = mtvec;
        mret_pc = mepc;
        mie_out = mstatus[2];

        if (csr_read_en) begin
            
            case(csr_addr)

                MSTATUS : csr_read_data = mstatus;
                MTVEC   : csr_read_data = mtvec;
                MEPC    : csr_read_data = mepc;
                MCAUSE  : csr_read_data = mcause;
                default : csr_read_data = 32'b0;

            endcase

        end

    end

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            
            mstatus <= 32'h00001800;
            mtvec <= 32'b0;
            mepc <= 32'b0;
            mcause <= 32'b0;

        end

        else if (trap_take) begin

            if (trap_cause ==  32'h0000000B || trap_cause == 32'h00000003) begin
                mepc <= pc + 4;
            end
            else begin
                mepc <= pc;
            end
    
            mcause <= trap_cause;
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;

        end

        else if (mret_take) begin
            
            mstatus[3] <= mstatus[7];
            mstatus[7] <= 1'b1;

        end

        else if (csr_wr_en) begin
            
            case(csr_addr)

            MSTATUS : begin
                
                case(csr_op)

                2'b00 : mstatus <= csr_wr_data;              //CSRRW
                2'b01 : mstatus <= (mstatus | csr_wr_data);  //CSRRS
                2'b11 : mstatus <= (mstatus & ~csr_wr_data); //CSRRC
                default : mstatus <= csr_wr_data;

                endcase

            end
            
            MTVEC : begin
                
                case(csr_op)

                2'b00 : mtvec <= csr_wr_data;            // CSRRW
                2'b01 : mtvec <= (mtvec | csr_wr_data);  // CSRRS
                2'b11 : mtvec <= (mtvec & ~csr_wr_data); // CSRRC
                default : mtvec <= csr_wr_data;

                endcase

            end

            MEPC : begin
                
                case(csr_op)

                2'b00 : mepc <= csr_wr_data;           // CSRRW  
                2'b01 : mepc <= (mepc | csr_wr_data);  // CSRRS
                2'b11 : mepc <= (mepc & ~csr_wr_data); // CSRRC
                default : mepc <= csr_wr_data;

                endcase

            end

            MCAUSE : begin
                
                case(csr_op)

                2'b00 : mcause <= csr_wr_data;             // CSRRW 
                2'b01 : mcause <= (mcause | csr_wr_data);  // CSRRS
                2'b11 : mcause <= (mcause & ~csr_wr_data); // CSRRC
                default : mcause <= csr_wr_data;

                endcase

            end

            default : begin

            end

            endcase

        end

    end 

endmodule