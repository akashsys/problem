`timescale 1ns/1ps
module alu (
    input         clk,
    input         rst_n,

    input         alu_pwr_en,
    input         iso_en,

    input  [15:0] A,
    input  [15:0] B,
    input  [3:0]  opcode,
    input         start,

    output reg [15:0] result,
    output            busy
);

    reg [1:0] state, next_state;
    localparam IDLE     = 2'b00,
               MUL_EXEC = 2'b01,
               DIV_EXEC = 2'b10;

    reg [3:0] cycle_cnt;

    /* FSM next-state */
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start && alu_pwr_en) begin
                    if (opcode == 4'b1000)
                        next_state = MUL_EXEC;
                    else if (opcode == 4'b1001)
                        next_state = DIV_EXEC;
                end
            end
            MUL_EXEC: if (cycle_cnt == 4) next_state = IDLE;
            DIV_EXEC: if (cycle_cnt == 8) next_state = IDLE;
        endcase
    end

    /* FSM state */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else if (!alu_pwr_en)
            state <= IDLE;
        else
            state <= next_state;
    end

    /* Cycle counter */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_cnt <= 4'd0;
        else if (!alu_pwr_en)
            cycle_cnt <= 4'd0;
        else if (state == IDLE)
            cycle_cnt <= 4'd0;
        else
            cycle_cnt <= cycle_cnt + 1'b1;
    end

    assign busy = (state == MUL_EXEC || state == DIV_EXEC);

    /* RESULT REGISTER */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result <= 16'd0;
        else if (!alu_pwr_en)
            result <= result;
        else begin
            case (opcode)
                4'b0000: result <= A + B;                      // ADD
                4'b0001: result <= A - B;                      // SUB
                4'b0010: result <= A & B;                      // AND
                4'b0011: result <= A | B;                      // OR
                4'b0100: result <= A ^ B;                      // XOR
                4'b0101: result <= ~(A | B);                   // NOR
                4'b0110: result <= A << B[3:0];                // SLL
                4'b0111: result <= ~(A ^ B);                   // XNOR
                4'b1000: if (state == MUL_EXEC && cycle_cnt == 4)
                             result <= A * B;                  // MUL
                4'b1001: if (state == DIV_EXEC && cycle_cnt == 8)
                             result <= (B != 0) ? A / B : 16'd0; // DIV
            endcase
        end
    end

endmodule
