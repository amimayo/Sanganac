module ALU (
    input [7:0] alucode,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [63:0] rd
);


    always @(*) begin
    
        case(alucode)

        8'd1 : rd = rs1 + rs2 ; //ADD
        8'd2 : rd = rs1 - rs2 ; //SUB
        8'd3 : rd = rs1 * rs2 ; //MUL
        8'd4 : rd = (rs2 == 0) ? -1 : $signed(rs1) / $signed(rs2) ; //DIV
        8'd5 : rd = (rs2 == 0) ? rs1 : $signed(rs1) % $signed(rs2) ; //REM
        8'd6 : rd = rs1 & rs2 ; //AND
        8'd7 : rd = rs1 | rs2 ; //OR
        8'd8 : rd = rs1 ^ rs2 ; //XOR
        8'd9 : rd = rs1 << rs2[4:0] ; //SLL
        8'd10 : rd = rs1 >> rs2[4:0] ; //SRL
        8'd11 : rd = $signed(rs1) >>> rs2[4:0] ; //SRA
        8'd12 : rd = (rs2 == 0) ? -1 : rs1 / rs2 ; //DIVU
        8'd13 : rd = (rs2 == 0)  ? rs1 : rs1 % rs2 ;  //REMU
        8'd14 : rd = ($signed(rs1) < $signed(rs2)) ? 64'd1 : 64'd0 ; //SLT
        8'd15 : rd = (rs1 < rs2) ? 64'd1 : 64'd0 ; //SLTU
        8'd16 : rd = $signed(rs1) * $signed(rs2) ; //MULH
        8'd17 : rd = $signed(rs1) * $signed({1'b0, rs2}) ; //MULHSU
        default : rd = 0 ; //DEFAULT

        endcase

    end
  
endmodule