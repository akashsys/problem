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
    input         save,
    input         restore,
    output [15:0] result
);

    wire [15:0] alu_result;
    wire        result_valid;
    wire        busy;

    reg  [15:0] alu_to_aon;
    reg  [15:0] saved_result;

    wire [15:0] data_out;

    alu u_alu (
        .clk(clk),
        .rst_n(rst_n),

        .alu_pwr_en(alu_pwr_en),
        .iso_en(iso_en),
        .save(save),
        .restore(restore),

        .A(A),
        .B(B),
        .opcode(opcode),
        .start(start),

        .result(alu_result),
        .result_valid(result_valid),
        .busy(busy)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            saved_result <= 16'd0;
        else if (save)
            saved_result <= alu_result;  
    end

    always @(*) begin
        if (restore)
            alu_to_aon = saved_result;
        else if (iso_en)
            alu_to_aon = saved_result;
        else if (!alu_pwr_en)
            alu_to_aon = saved_result;
        else
            alu_to_aon = alu_result;
    end

    aon_block u_aon (
        .clk(clk),
        .rst_n(rst_n),
        .alu_out(alu_to_aon),
        .data_out(data_out)
    );

    assign result = data_out;

endmodule

