`timescale 1ns/1ps
module aon_block (
    input         clk,
    input         rst_n,
    input  [15:0] alu_out,      // Comes from PD_ALU
    output reg [15:0] data_out  // Stored in PD_AON
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 16'd0;
        else
            data_out <= alu_out; // Domain crossing occurs HERE
    end

endmodule
