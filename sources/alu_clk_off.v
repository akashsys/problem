module alu_clk_off (
    input  wire clk,
    input  wire diss_clk,
    output wire alu_clk
);

    assign alu_clk = diss_clk ? 1'b0 : clk;

endmodule
