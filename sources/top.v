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

    reg  [15:0] alu_to_aon;
    wire [15:0] data_out;

    // ---------------- ALU ----------------
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

    // ---------------- PIPELINE FIX ----------------
    // Capture ALU result AFTER it updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            alu_to_aon <= 16'd0;
        else if (iso_en)
            alu_to_aon <= 16'd0;          // BUG2 hook
        else if (!alu_pwr_en)
            alu_to_aon <= 16'd0;          // BUG3 hook
        else
            alu_to_aon <= alu_result;     // correct timing
    end

    // ---------------- AON ----------------
    aon_block u_aon (
        .clk(clk),
        .rst_n(rst_n),
        .alu_out(alu_to_aon),
        .data_out(data_out)
    );

    assign result = data_out;

endmodule


