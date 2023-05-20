`timescale 1ns/1ps

module instr_cont (
    input  wire clk,
    input  wire rst,
    input  wire en,

    output wire [31:0] pc4,
    output wire [31:0] instr_addr,
    input  wire [31:0] instr,
    input  wire [31:0] rjump_addr, // register jump addr

    input  wire jump,
    input  wire jump_dst,          // if asserted, do jump on the register
    input  wire branch,
    );

    assign pc4 = instr_addr + 32'h0000_0004;

    reg [31:0] next_addr;

    PC pc(.clk(clk), 
          .rst(rst), 
          .en(en),
          .d(next_addr),
          .q(instr_addr));

    always_comb begin
        case ({jump, branch})
            2'b00: next_addr = pc4;
            2'b01: next_addr = pc4 + {{14{instr[15]}}, instr[15:0], 2'b00};
            default: next_addr = jump_dst ? rjump_addr : {instr_addr[31:28], instr[25:0], 2'b00};
        endcase 
    end
endmodule
