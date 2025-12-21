`timescale 1ns/1ps
module top (
    input         clk,
    input         rst_n,

    input  [15:0] A,
    input  [15:0] B,
    input  [3:0]  opcode,
    input         start,

    input         diss_clk,

    output reg  [15:0] result,
    output wire [15:0] clamp_obs
);

    wire [15:0] alu_result;
    wire        busy;
    wire        alu_clk;

    wire [15:0] clamp_value;
    assign clamp_value = 16'd0;
    assign clamp_obs   = clamp_value;

    alu_clk_off u_clk_off (
        .clk      (clk),
        .diss_clk (diss_clk),
        .alu_clk  (alu_clk)
    );

    alu u_alu (
        .clk    (alu_clk),
        .rst_n  (rst_n),
        .A      (A),
        .B      (B),
        .opcode (opcode),
        .start  (start),
        .result (alu_result),
        .busy   (busy)
    );

    always @(*) begin
        if (!rst_n)
            result = 16'd0;
        else if (diss_clk)
            result = clamp_value;
        else
            result = alu_result;
    end

endmodule

