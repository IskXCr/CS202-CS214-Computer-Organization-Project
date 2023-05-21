`timescale 1ns/1ps

module instr_cont #(parameter TEXT_BASE_ADDR = 32'h0040_0000) (
    input  wire clk,
    input  wire rst,
    input  wire en,

    output wire [31:0] pc4,
    output wire [31:0] instr_addr,
    input  wire [25:0] instr,
    input  wire [31:0] rjump_addr, // register jump addr

    input  wire jump,
    input  wire jump_dst,          // if asserted, do jump on the register
    input  wire branch
    );
    
    wire [31:0] current_addr;

    reg [31:0] next_addr;

    assign pc4 = current_addr + 32'h0000_0004;

    PC #(TEXT_BASE_ADDR) pc(.clk(clk), 
                            .rst(rst), 
                            .en(en),
                            .d(instr_addr),
                            .q(current_addr));

    always_comb begin
        casez ({jump, branch, jump_dst})
            3'b00?: next_addr = pc4;
            3'b01?: next_addr = pc4 + {{14{instr[15]}}, instr[15:0], 2'b00};
            3'b1?0: next_addr = {current_addr[31:28], instr[25:0], 2'b00};
            3'b1?1: next_addr = rjump_addr;
            default: next_addr = pc4;
        endcase 
    end
    
    assign instr_addr = next_addr;
    
endmodule
