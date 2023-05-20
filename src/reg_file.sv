`timescale 1ns/1ps

module reg_file(
	input  wire clk,
	input  wire we,
	input  wire [4:0]  ra1, // read addr 1
    input  wire [4:0]  ra2, // read addr 2
    input  wire [4:0]  wa,  // write addr
	input  wire [31:0] wd,  // write data
    
	output wire [31:0] rd1, // read data 1
    output wire [31:0] rd2  // read data 2
    );

	reg [31:0] reg_files[31:0];

	always @(posedge clk) begin
		if(we && wa != 5'd0) begin
			 reg_files[wa] <= wd;
		end
	end

	assign rd1 = (ra1 != 0) ? reg_files[ra1] : 0;
	assign rd2 = (ra2 != 0) ? reg_files[ra2] : 0;
endmodule
