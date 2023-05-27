`timescale 1ns/1ps

module ALU_dec (
    input  wire [5:0]  ALU_op,     // ALU internal op code
    input  wire [5:0]  funct,      // function code

    output wire shift_src,         // 1 for selecting the register rs
    output wire shift_dir,         // 1 for right shift
    output wire shift_ari,         // 1 for arithmetic shift
    output wire do_unsigned,       // 1 to do unsigned operation

    output wire ALU_src,           // 1 to use the immediate
    output wire use_sign_imm,      // 1 to use the signed_immediate instead of the unsigned

    output wire ALU_reg_write,     // 1 to let ALU write results into hi/lo register
    output wire ALU_reg_sel,       // 0 for selecting the hi register, 1 for selecting the lo register

    output reg  [3:0]  ALU_control
    );

    assign shift_src = funct[2];
    assign do_unsigned = ((ALU_op == 6'b000000) & funct[5] & funct[0]) | (ALU_op[3] & ALU_op[0]);
    assign ALU_src = ALU_op[3] | ALU_op[5]; // immediate arithmetic/logical operations OR memory access operations
    assign use_sign_imm = (ALU_src & ~ALU_op[2]) | ALU_op[5]; // immediate arithmetic/logical operations OR memory access operations
    assign ALU_reg_write = ((ALU_op == 6'b000000) && (funct[5:2] == 4'b0100) && (funct[0] == 1'b1));
    assign ALU_reg_sel = funct[1]; // select the operand

    // ALU_control
    always_comb begin
        if (ALU_op == 6'b000000) begin
        // R-type
            casez (funct)
                // logical
                6'b100100: ALU_control = 4'h1;
                6'b100101: ALU_control = 4'h2;
                6'b100110: ALU_control = 4'h3;
                6'b100111: ALU_control = 4'h4;

                // shift
                6'b000???: ALU_control = 4'h6;

                // arithmetic
                6'b10000?: ALU_control = 4'h7;
                6'b10001?: ALU_control = 4'h8;
                6'b10101?: ALU_control = 4'h9;
                6'b01100?: ALU_control = 4'hA; // mul
                6'b01101?: ALU_control = 4'hB; // div

                // data retrieval
                6'b0100?0: ALU_control = 4'hC; // mfhi/mflo

                default:   ALU_control = 4'h0; 
            endcase
        end
        else begin
        // I-type
            casez (ALU_op)
                // logical
                6'b001100: ALU_control = 4'h1;
                6'b001110: ALU_control = 4'h3;
                6'b001111: ALU_control = 4'h5;
                6'b001101: ALU_control = 4'h2;

                // arithmetic
                6'b00100?: ALU_control = 4'h7;
                6'b00101?: ALU_control = 4'h9;

                // memory
                6'b10????: ALU_control = 4'h7; // same as add for all memory operations

                // branch - ALU has built-in comparator
                default:   ALU_control = 4'h0;
            endcase
        end
    end

    // shift_dir
    assign shift_dir = funct[1];
    assign shift_ari = funct[0];

endmodule
