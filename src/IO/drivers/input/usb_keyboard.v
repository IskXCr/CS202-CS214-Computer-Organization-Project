`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/25 15:32:45
// Design Name: 
// Module Name: usb_keyboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module usb_keyboard(
    input             clk,
    input             rst,
    inout             USB_CLOCK,
    inout             USB_DATA,
    output reg [7:0] output_data
);

// USB ports control
wire   USB_CLOCK_OE;
wire   USB_DATA_OE;
wire   USB_CLOCK_out;
wire   USB_CLOCK_in;
wire   USB_DATA_out;
wire   USB_DATA_in;
reg state[3:0];
assign USB_CLOCK = (USB_CLOCK_OE) ? USB_CLOCK_out : 1'bz;
assign USB_DATA = (USB_DATA_OE) ? USB_DATA_out : 1'bz;
assign USB_CLOCK_in = USB_CLOCK;
assign USB_DATA_in = USB_DATA;

wire       PS2_valid;
wire [7:0] PS2_data_in;
wire       PS2_busy;
wire       PS2_error;
wire       PS2_complete;
reg        PS2_enable;
reg  [7:0] PS2_data_out;

// Controller for the PS2 port
// Transfer parallel 8-bit data into serial, or receive serial to parallel
transmitter transmitter(
    .clk(clk),
    .rst(rst),
    
    .clock_in(USB_CLOCK_in),
    .serial_data_in(USB_DATA_in),
    .parallel_data_in(PS2_data_in),
    .parallel_data_valid(PS2_valid),
    .busy(PS2_busy),
    .data_in_error(PS2_error),
    
    .clock_out(USB_CLOCK_out),
    .serial_data_out(USB_DATA_out),
    .parallel_data_out(PS2_data_out),
    .parallel_data_enable(PS2_enable),
    .data_out_complete(PS2_complete),
    
    .clock_output_oe(USB_CLOCK_OE),
    .data_output_oe(USB_DATA_OE)
);
always @(posedge clk) begin
case (PS2_data_in) 
    8'h45, 8'h16, 8'h1e, 8'h26, 8'h25, 8'h2e, 8'h36, 8'h3d, 8'h3e, 8'h46, 8'h1c, 8'h32, 8'h21, 8'h23, 8'h24, 8'h2b:
        output_data[7:4] <= output_data[3:0];
    default:
        output_data[7:4] <= output_data[7:4];
endcase
end
always @(posedge clk or posedge rst) begin
  if (rst) begin
    output_data[3:0] <= output_data[3:0];
  end else begin
    case (PS2_data_in)
      8'h45: output_data[3:0] <= 4'h0;
      8'h16: output_data[3:0] <= 4'h1;
      8'h1e: output_data[3:0] <= 4'h2;
      8'h26: output_data[3:0] <= 4'h3;
      8'h25: output_data[3:0] <= 4'h4;
      8'h2e: output_data[3:0] <= 4'h5;
      8'h36: output_data[3:0] <= 4'h6;
      8'h3d: output_data[3:0] <= 4'h7;
      8'h3e: output_data[3:0] <= 4'h8;
      8'h46: output_data[3:0] <= 4'h9;
      8'h1c: output_data[3:0] <= 4'hA;
      8'h32: output_data[3:0] <= 4'hB;
      8'h21: output_data[3:0] <= 4'hC;
      8'h23: output_data[3:0] <= 4'hD;
      8'h24: output_data[3:0] <= 4'hE;
      8'h2b: output_data[3:0] <= 4'hF;
      default: output_data[3:0] <= output_data[3:0];
    endcase
  end
end

endmodule