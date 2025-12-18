`timescale 1ns/1ps
module alu (
    input         clk,
    input         rst_n,

    // Power control
    input         alu_pwr_en,
    input         iso_en,
    input         save,
    input         restore,

    // ALU interface
    input  [15:0] A,
    input  [15:0] B,
    input  [3:0]  opcode,
    input         start,

    output reg [15:0] result,
    output reg        result_valid,
    output reg        busy
);

    // =========================================================================
    // FSM
    // =========================================================================
    reg [1:0] state, next_state;
    localparam IDLE     = 2'b00,
               MUL_EXEC = 2'b01,
               DIV_EXEC = 2'b10;

    reg [3:0] cycle_cnt;

    // =========================================================================
    // Next State Logic
    // =========================================================================
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start) begin
                    if (opcode == 4'b1000)      next_state = MUL_EXEC; // MUL
                    else if (opcode == 4'b1001) next_state = DIV_EXEC; // DIV
                end
            end

            MUL_EXEC: if (cycle_cnt == 4) next_state = IDLE;
            DIV_EXEC: if (cycle_cnt == 8) next_state = IDLE;

        endcase
    end

    // =========================================================================
    // State Register
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else if (!alu_pwr_en)
            state <= IDLE;  // freeze on power down
        else
            state <= next_state;
    end

    // =========================================================================
    // Cycle Counter
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_cnt <= 0;
        else if (!alu_pwr_en)
            cycle_cnt <= cycle_cnt; // freeze
        else if (state == IDLE)
            cycle_cnt <= 0;
        else
            cycle_cnt <= cycle_cnt + 1;
    end

    // =========================================================================
    // BUSY & RESULT_VALID generation
    // =========================================================================
    always @(*) begin
        busy = (state == MUL_EXEC || state == DIV_EXEC);

        result_valid = 0;

        // Single-cycle ops
        if (state == IDLE && start && opcode <= 4'b0111)
            result_valid = 1;

        // Multi-cycle finish
        else if (state == MUL_EXEC && cycle_cnt == 4)
            result_valid = 1;
        else if (state == DIV_EXEC && cycle_cnt == 8)
            result_valid = 1;
    end

    // =========================================================================
    // MAIN RESULT Register (Sequential)
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result <= 16'd0;

        else if (!alu_pwr_en)
            result <= result;  // Freeze output

        else if (result_valid) begin
            case (opcode)

                // Single-cycle arithmetic/logical ops
                4'b0000: result <= A + B;          // ADD
                4'b0001: result <= A - B;          // SUB
                4'b0010: result <= A & B;          // AND
                4'b0011: result <= A | B;          // OR
                4'b0100: result <= A ^ B;          // XOR
                4'b0101: result <= ~(A | B);       // NOR
                4'b0110: result <= A << B[3:0];    // SLL
                4'b0111: result <= A << B[3:0];    // SLL

                // Multi-cycle operations (final cycle)
                4'b1000: result <= A * B;                    // MUL
                4'b1001: result <= (B != 0) ? A / B : 16'd0; // DIV

            endcase
        end
    end

    // =========================================================================
    // Isolation logic
    // =========================================================================
    reg [15:0] result_iso;

    always @(*) begin
        if (iso_en)
            result_iso = 16'd0;
        else
            result_iso = result;
    end

endmodule
