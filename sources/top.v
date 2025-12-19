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

    output reg [15:0] result
);

    wire [15:0] alu_result;
    wire        busy;

    // Clamp value
    wire [15:0] clamp_value;
    assign clamp_value = 16'd1;

    // ALU instance
    alu u_alu (
        .clk        (clk),
        .rst_n      (rst_n),
        .alu_pwr_en (alu_pwr_en),
        .iso_en     (iso_en),
        .A          (A),
        .B          (B),
        .opcode     (opcode),
        .start      (start),
        .result     (alu_result),
        .busy       (busy)
    );

always @(*) begin
    if (!rst_n)
        result = 16'd0;
    else if (iso_en)
        result = clamp_value;
    else if (!alu_pwr_en)
        result = clamp_value;
    else
        result = alu_result;
end

endmodule



