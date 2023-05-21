`timescale 1ns/1ps

module branch_cont (
    input  wire cont_branch,
    input  wire [5:0] op,
    input  wire [4:0] link,  // instr[20:16]

    input  wire ALU_lt,
    input  wire ALU_eq,

    output reg  branch
    );

    always_comb begin
        if (cont_branch) begin
            if (op == 6'b000001) begin
                // branch and link instructions. Judge rt to continue
                case (link)
                    5'b00000: branch = ALU_lt;  // bltz
                    5'b10000: branch = ALU_lt;  // bltzal
                    5'b00001: branch = ~ALU_lt; // bgez
                    5'b10001: branch = ~ALU_lt; // bgezal
                    default:  branch = 0;       // illegal
                endcase
            end
            else begin
                case (op)
                    6'b000100: branch = ALU_eq;                // beq
                    6'b000111: branch = (~ALU_lt) & (~ALU_eq); // bgtz
                    6'b000110: branch = ALU_lt | ALU_eq;       // blez
                    6'b000101: branch = ~ALU_eq;               // bne
                    default:   branch = 0;
                endcase
            end
        end
        else begin
            branch = 0;
        end
    end


endmodule
