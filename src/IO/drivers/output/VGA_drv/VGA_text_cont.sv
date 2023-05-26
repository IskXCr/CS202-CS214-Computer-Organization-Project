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

    ///////////////////////////////////////////////////
    // load registers
    // TODO: check endianness
    wire [6:0]   font_bmap_addr;
    wire [127:0] font_bmap_out;

    font_mem font_memory(.clka(dri_clk),
                         .addra(font_bmap_addr),
                         .douta(font_bmap_out));


    ///////////////////////////////////////////////////
    // prefetch 
    parameter integer C_H_ACTIVE_TIME = 12'd640,
                      C_V_ACTIVE_TIME = 12'd480;
    parameter integer C_H_CHAR_CNT    = 12'd80,
                      C_V_CHAR_CNT    = 12'd30;

    // position calculation
    wire [9:0]  pre_pos_x, pre_pos_y;

    assign pre_pos_x = (sgn_pos_x == C_H_ACTIVE_TIME) ? 
                                                    0 : sgn_pos_x + 1;
    assign pre_pos_y = (sgn_pos_y == C_V_ACTIVE_TIME) ? 
                                                    0 : ((sgn_pos_x != C_H_ACTIVE_TIME) ? 
                                                                              sgn_pos_y : sgn_pos_y + 1);

    wire [11:0] c_prefetch_idx; // index of the word of the NEXT character in text buffer
    wire [1:0]  c_buf_offset;   // offset of the NEXT character in the word

    assign c_prefetch_idx = pre_pos_y[9:4] * C_H_CHAR_CNT + pre_pos_x[9:3];
    assign cont_buf_addr  = c_prefetch_idx[11:2];

    assign c_buf_offset  = c_prefetch_idx[1:0];

    ///////////////////////////////////////////////////
    // fetch the next character bitmap
    wire [7:0] chars[0:3];
    
    assign chars[0] = cont_buf_data[7:0];
    assign chars[1] = cont_buf_data[15:8];
    assign chars[2] = cont_buf_data[23:16];
    assign chars[3] = cont_buf_data[31:24];

    // for debugging purpose
    wire [7:0]   c_sel_char; // selected char to be displayed next
    wire [127:0] c_cur_data; // selected data to be used next
    
    assign c_sel_char = chars[c_buf_offset];
    assign c_cur_data = font_bmap_out;

    assign font_bmap_addr = c_sel_char[6:0];

    
    wire [6:0] c_bmap_x,       // CURRENT character bitmap x coord
               c_bmap_y,       // CURRENT character bitmap y coord
               c_bmap_mem_idx; // CURRENT character bitmap offset

    assign c_bmap_x       = {4'b0000, sgn_pos_x[2:0]};
    assign c_bmap_y       = {3'b000, sgn_pos_y[3:0]};
    assign c_bmap_mem_idx = {c_bmap_y[3:0], c_bmap_x[2:0]};
    
    assign color_out = (c_cur_data[c_bmap_mem_idx] == 1'b1 ) ? 12'hfff : 12'h000;

endmodule