`timescale 1ns/1ps

module main_decoder(
    input  wire [5:0] op,

    output wire mem_to_reg,
    output wire mem_write,
    output wire branch,
    output wire reg_write,
    output wire [1:0] reg_dst, // 0 - rt, 1 - rd, 2 - ra
    output wire reg_pc4_src,   // if asserted, select PC+4 as write_data to the register
    output wire jump,
    output wire jump_dst       // if asserted, select a register as the jump destination
    );

    reg [5:0] controls;

    assign {reg_write, reg_dst, reg_pc_src, branch, mem_write, mem_to_reg, jump, jump_dst} = controls;

    always_comb begin
        casez (op)
            6'b000000: controls = 9'b1_01_000000; // R-Type
            6'b100???: controls = 9'b1_00_000100; // load
            6'b101???: controls = 9'b0_00_001000; // save
            6'b0001??: controls = 9'b0_00_010000; // branch
            6'b000001: controls = 9'b0_10_010000; // branch and link $ra
            6'b000000: controls = 9'b1_01_100011; // jump register (and link)
            6'b00001?: controls = 9'b0_00_000010; // jump instr_index
            default:   controls = 9'b0_00_000000; // nop
        endcase
    end

endmodule