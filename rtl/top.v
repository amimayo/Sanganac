module TOP (
    input clk,
    input reset
);

    RISCV_CORE sanganac (
        .clk(clk),
        .reset(reset)
    );

endmodule