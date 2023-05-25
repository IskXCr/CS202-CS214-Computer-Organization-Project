`timescale 1ns/1ps
// reference: https://github.com/IskXCr/CS211-Project-Flappy-Bird/blob/main/Source/VGA_DRIVER.sv
// reference: slides from SUSTech CS211 Digital Logic

module VGA_driver(
    input  wire clk,           // clk base frequency: 100 MHz
    input  wire rst,           // high active
    
    input  wire [11:0] v_data, // input color data in RGB444 format
    output wire [3:0]  red,
    output wire [3:0]  green,
    output wire [3:0]  blue,
    output wire        hsync,
    output wire        vsync,
    output wire [11:0] pos_x,  // output current rendering position. v_data must be ready at this position.
    output wire [11:0] pos_y   // output current rendering position. v_data must be ready at this position.
    );
    
    wire dri_clk; // dri_clk should be at 
    clk_wiz_1 clk_gen(.clk_in1(clk), .clk_out1(dri_clk), .reset(1'b0));
    
    
    // VGA MODE SPECIFICATION
    // mode: 640*480 @60Hz
    parameter integer   RES_H = 12'd640,
                        RES_V = 12'd480;
    // Horizontal
    parameter integer   C_H_SYNC_PULSE  =   12'd96,     // a
                        C_H_BACK_PORCH  =   12'd48,    // b
                        C_H_ACTIVE_TIME =   12'd640,   // c
                        C_H_FRONT_PORCH =   12'd16,     // d
                        C_H_LINE_PERIOD =   12'd800;   // e
    // vertical 
    parameter integer   C_V_SYNC_PULSE  =   12'd2,      // a
                        C_V_BACK_PORCH  =   12'd33,     // b
                        C_V_ACTIVE_TIME =   12'd480,   // c
                        C_V_FRONT_PORCH =   12'd10,      // d
                        C_V_FRAME_PERIOD=   12'd525;   // e
    

    // horizontal counter
    reg  [11:0] hc;

    assign pos_x = (hc >= C_H_SYNC_PULSE + C_H_BACK_PORCH) ? hc - (C_H_SYNC_PULSE + C_H_BACK_PORCH) : 0;

    always @(posedge dri_clk) begin
       if(rst)
           hc <= 0;
       else if(hc == C_H_LINE_PERIOD - 1)
           hc <= 0;
       else
           hc <= hc + 1;
    end
    

    // vertical counter
    reg [11:0] vc;

    assign pos_y = (vc >= C_V_SYNC_PULSE + C_V_BACK_PORCH) ? vc - (C_V_SYNC_PULSE + C_V_BACK_PORCH) : 0;

    always @(posedge dri_clk) begin
       if(rst)
           vc <= 0;
       else if(vc == C_V_FRAME_PERIOD - 1 && hc == C_H_LINE_PERIOD - 1)
           vc <= 0;
       else if(hc == C_H_LINE_PERIOD - 1)
           vc <= vc + 1;
       else
           vc <= vc;
    end
    

    // sync and color signals
    assign hsync = (hc < C_H_SYNC_PULSE) ? 0 : 1;
    assign vsync = (vc < C_V_SYNC_PULSE) ? 0 : 1;

    wire active = (hc >= (C_H_SYNC_PULSE + C_H_BACK_PORCH)) && 
                  (hc < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME)) &&
                  (vc >= (C_V_SYNC_PULSE + C_V_BACK_PORCH)) && 
                  (vc < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME)) ? 1 : 0;
                  
    assign {red, green, blue} = (rst == 1 || ~active) ? 12'h000 : v_data;
    
endmodule