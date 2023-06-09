`timescale 1ns/1ps

module ALU (
    input  wire clk,
    input  wire rst,

    input  wire [3:0] ALU_control, // ALU internal control code
    input  wire [4:0] shamt,              // shift amount
    input  wire shift_dir,          // 1 for right shift
    input  wire shift_ari,          // 1 for arithmetic shift
    input  wire do_unsigned,        // 1 to do unsigned operation

    input  wire ALU_reg_write,     // 1 to let ALU write results into hi/lo register
    input  wire ALU_reg_sel,       // 0 for selecting the hi register, 1 for selecting the lo register

    input  wire [31:0] op_1,
    input  wire [31:0] op_2,
    
    output wire ALU_eq,             // if high, op_1 is equal to op_2
    output reg  ALU_lt,             // if high, op_1 is less than op_2
    output reg  overflow,           // if set, the arithmetic result causes an overflow
    output reg  [31:0] ALU_out
    );

    // wires and regs
    wire [31:0] shift_res;

    wire [63:0] mul_res;
    wire [31:0] div_quot, div_rem; // quotient and remainder, as suggested
    reg  [31:0] hi, lo;            // hi and lo register

    reg  [31:0] op_res;            // intermediate arithmetic results other than op shift and mul/div

    // module instances
    shifter shifter_0(.d(op_2), 
                      .shamt(shamt), 
                      .dir(shift_dir), 
                      .ari(shift_ari), 
                      .q(shift_res));

    // mul/div
    assign mul_res  = (do_unsigned) ? (op_1 * op_2) : ($signed(op_1) * $signed(op_2));
    assign div_quot = (do_unsigned) ? (op_1 / op_2) : ($signed(op_1) / $signed(op_2));
    assign div_rem  = (do_unsigned) ? (op_1 % op_2) : ($signed(op_1) % $signed(op_2));

    // manipulate hi/lo registers
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            hi <= 32'h0000_0000;
            lo <= 32'h0000_0000;
        end
        else begin
            case (ALU_control)
                4'hA: begin
                    hi <= mul_res[63:32];
                    lo <= mul_res[31:0];
                end
                4'hB: begin
                    hi <= div_rem;
                    lo <= div_quot;
                end
                default: begin
                    hi <= (ALU_reg_write && ~ALU_reg_sel) ? op_1 : hi;
                    lo <= (ALU_reg_write && ALU_reg_sel) ? op_1 : lo;
                end
            endcase
        end
    end

    // op_res
    always_comb begin
        case (ALU_control)
            4'h1: op_res = op_1 & op_2;
            4'h2: op_res = op_1 | op_2;
            4'h3: op_res = op_1 ^ op_2;
            4'h4: op_res = ~(op_1 | op_2);
            4'h5: op_res = op_2 << 16;
            4'h7: op_res = op_1 + op_2;
            4'h8: op_res = $signed(op_1) - $signed(op_2);

            default: op_res = 32'h0000_0000;
        endcase
    end

    // ALU_out
    always_comb begin
        case (ALU_control)
            4'h6: ALU_out = shift_res;
            4'h9: ALU_out = {31'd0, ALU_lt};
            4'hC: ALU_out = (ALU_reg_sel) ? lo : hi;
            default: ALU_out = op_res;
        endcase
    end

    // ALU_lt
    always_comb begin
        if (do_unsigned)
            ALU_lt = (op_1 < op_2);
        else
            ALU_lt = ($signed(op_1) < $signed(op_2));
    end
    
    // ALU_eq
    assign ALU_eq = (op_1 == op_2);

    // overflow
    always_comb begin
        if (ALU_control == 4'h7 && op_1[31] == op_2[31] && op_1[31] != op_res[31]) begin
            overflow = 1'b1;
        end
        else if (ALU_control == 4'h8 && op_1[31] != op_2[31] && op_res[31] != op_1[31]) begin
            overflow = 1'b1;
        end
        else begin
            overflow = 1'b0;
        end
    end

endmodule
