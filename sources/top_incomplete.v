// ============================================================================
// TOP MODULE  (INTENTIONALLY INCOMPLETE)
// Agent must complete result propagation correctly
// ============================================================================

module top (
    input         clk,
    input         rst_n,

    // ALU input controls
    input  [15:0] A,
    input  [15:0] B,
    input  [3:0]  opcode,
    input         start,

    // Power control
    input         alu_pwr_en,
    input         iso_en,
    input         save,
    input         restore,

    // Final visible output
    output reg [15:0] result
);

    // Internal wires
    wire [15:0] alu_result;
    wire        result_valid;
    wire        busy;

    // =========================================================================
    // ALU Instance (PD_ALU)
    // =========================================================================
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

    // =========================================================================
    // Always-On Block (PD_AON)
    // =========================================================================
    wire [15:0] aon_data;

    aon_block u_aon (
        .clk(clk),
        .rst_n(rst_n),
        .alu_out(alu_result),
        .data_out(aon_data)
    );

    // =========================================================================
    // TODO SECTION (AGENT MUST FIX)
    // =========================================================================

    /*
     * TODO-1:
     * Decide WHEN result should update.
     * Hint: result_valid is meaningful.
     */

    /*
     * TODO-2:
     * Ensure result does not update with invalid or X data.
     */

    /*
     * TODO-3:
     * Make sure power / isolation does not permanently zero the output.
     */

    // Intentionally broken logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result <= 16'd0;
        else
            result <= result; // BUG: result never updates
    end

endmodule
