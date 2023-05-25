`timescale 1ns/1ps

// CAUTION: this module is tailored for 480p.
//          If you are to change this, you must also refactor other parts where suitness for 480p is explicitly stated.
module VGA_text_cont(
    input  wire dri_clk,
    input  wire rst,

    input  wire [9:0] sgn_pos_x, // current rendering position
    input  wire [9:0] sgn_pos_y, // current rendering position

    output wire [9:0]  cont_buf_addr, // word-aligned
    input  wire [31:0] cont_buf_data, // read 32 bits per clock cycle

    output wire [11:0] color_out
    );

    localparam MEM_FILE_LOC = "../../../../../mem/CP885.F16.memh";
    

    ///////////////////////////////////////////////////
    // load registers
    // TODO: check endianness
    reg [0:127] font_bmap [0:127]; // font_bitmap
    
    initial $readmemb(MEM_FILE_LOC, font_bmap);

    ///////////////////////////////////////////////////
    // prefetch 
    parameter integer C_H_ACTIVE_TIME = 12'd640,
                      C_V_ACTIVE_TIME = 12'd480;

    // position calculation
    wire [9:0]  pre_pos_x, pre_pos_y;

    assign pre_pos_x = (sgn_pos_x == C_H_ACTIVE_TIME) ? 
                                                    0 : sgn_pos_x + 1;
    assign pre_pos_y = (sgn_pos_y == C_V_ACTIVE_TIME) ? 
                                                    0 : ((sgn_pos_x != C_H_ACTIVE_TIME) ? 
                                                                              sgn_pos_y : sgn_pos_y + 1);

    wire [11:0] c_prefetch_idx; // index of the word of the NEXT character in text buffer

    assign c_prefetch_idx     = pre_pos_y[9:4] * C_H_ACTIVE_TIME + pre_pos_x[9:3];
    assign cont_buf_addr = c_prefetch_idx[11:2];


    ///////////////////////////////////////////////////
    // assign grabbed data simply to vout
    wire [6:0] c_bmap_x,       // character bitmap x coord
               c_bmap_y,       // character bitmap y coord
               c_bmap_mem_idx; // character bitmap offset

    wire [11:0] c_cur_idx;    // index of the CURRENT character in text buffer
    wire [1:0]  c_buf_offset; // offset of the CURRENT character in the word

    assign c_cur_idx     = sgn_pos_y[9:4] * C_H_ACTIVE_TIME + sgn_pos_x[9:3];
    assign c_buf_offset  = c_cur_idx[1:0];

    assign c_bmap_x       = {4'b0000, sgn_pos_x[2:0]};
    assign c_bmap_y       = {3'b000, sgn_pos_y[3:0]};
    assign c_bmap_mem_idx = {c_bmap_y, c_bmap_x};

    wire [7:0] chars[0:3];
    
    assign chars[0] = cont_buf_data[7:0];
    assign chars[1] = cont_buf_data[15:8];
    assign chars[2] = cont_buf_data[23:16];
    assign chars[3] = cont_buf_data[31:24];

    assign color_out = (font_bmap[chars[c_buf_offset]][c_bmap_mem_idx] == 1'b1 ) ? 12'h000 : 12'hfff;

endmodule