`timescale 1ns/1ps
module top (
    input         clk,
    input         rst_n,

    input  [15:0] A,
    input  [15:0] B,
    input  [3:0]  opcode,
    input         start,

    input         alu_pwr_en,
    input         iso_en,

    output [15:0] result
);

    initial begin
        $display("USING TOP VERSION : 2025-01-ALU");
    end

    wire [15:0] alu_result;
    wire        busy;

    alu u_alu (
        .clk(clk),
        .rst_n(rst_n),
        .alu_pwr_en(alu_pwr_en),
        .iso_en(iso_en),
        .A(A),
        .B(B),
        .opcode(opcode),
        .start(start),
        .result(alu_result),
        .busy(busy)
    );

    // --------- GOLDEN PATH (NO AON INTERFERENCE) ---------
    assign result = (iso_en || !alu_pwr_en) ? 16'd0 : alu_result;

endmodule

