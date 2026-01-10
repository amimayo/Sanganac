module ALU (
    input [7:0] alucode,
    input [31:0] rs1,
    input [31:0] rs2,
    output [63:0] rd
);


    always @(*) begin
        
        case(alucode)

        8'd1 : rd = rs1 + rs2 ; //ADD
        8'd2 : rd = rs1 - rs2 ; //SUB
        8'd3 : rd = rs1 * rs2 ; //MUL
        8'd4 : rd = rs1 / rs2 ; //DIV
        8'd5 : rd = rs1 % rs2; //REM
        8'd6 : rd = rs1 & rs2 ; //AND
        8'd7 : rd = rs1 | rs2 ; //OR
        8'd8 : rd = rs1 ^ rs2 ; //XOR
        8'd9 : rd = rs1 << rs2[4:0]; //SLL
        8'd10 : rd = rs1 >> rs2[4:0]; //SRL
        8'd11 : rd = $signed(rs1) >>> rs2[4:0]; //SRA
        default : rd = 0 ; //DEFAULT

        endcase

    end

   
endmodule