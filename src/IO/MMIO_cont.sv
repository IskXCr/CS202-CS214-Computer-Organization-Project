`timescale 1ns/1ps

module MMIO_cont(
    input  wire data_clk, // write data on posedge of this clk
    input  wire dri_clk,  // 100 MHz clk onboard.
    input  wire rst,      // clear writable memory

    input  wire [31:0] addr, // starting at 0x0000_0000
    input  wire [31:0] write_data,
    output wire [31:0] read_data, // for addr, return the data read on next posedge of this clk. addr starts from 0x00000000.
    input  wire wea,

    input  wire mode,
    input  wire overflow,
    input  wire instr_wen,
    input  wire data_wen,
    input  wire uart_done,
    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg,

    output wire [3:0]  vga_red,
    output wire [3:0]  vga_green,
    output wire [3:0]  vga_blue,
    output wire vga_hsync,
    output wire vga_vsync
    );
    
    
    // configure directedly mapped IOs
    assign led[23] = mode;
    assign led[22] = uart_done;
    assign led[21] = instr_wen;
    assign led[20] = data_wen;


    // --------MMIO Preparation--------
    // address conversion
    wire [3:0] real_addr;
    assign real_addr = addr[5:2];

    // MMIO out configuration
    reg  [31:0] mmio_regs  [0:15];
    wire [31:0] mmio_out_1 [0:15];
    wire [31:0] mmio_out_2;
    wire is_in_mmio_seg_2;
    
    assign mmio_out_1 = mmio_regs;
    assign read_data = is_in_mmio_seg_2 ? mmio_out_2 : mmio_out_1[real_addr];


    ///////////////////////////////////////////////////

    // MMIO Segment 1 - R enable

    ///////////////////////////////////////////////////

    // source 0x0000, reserved verification
    always_comb begin
        mmio_regs[0] = 32'h1234_ABCD;
    end
    

    ///////////////////////////////////////////////////

    // source: 0x0004, scenario switch
    wire [3:0] testcase;

    assign testcase[3] = switches[23];

    always_comb begin
        mmio_regs[1] = {31'h0000_0000, testcase[3]};
    end


    ///////////////////////////////////////////////////

    // source: 0x0008, testcase number
    assign testcase[2:0] = switches[22:20];

    always_comb begin
        mmio_regs[2] = {29'h0000_0000, testcase[2:0]};
    end


    ///////////////////////////////////////////////////

    // source: 0x000C, Operand 1
    // source: 0x0010, Operand 2
    wire [31:0] signed_op1, unsigned_op1, signed_op2, unsigned_op2;
    reg  [1:0]  op_comb; // if bit 1 asserted, select the signed imm for op1. Similar as the bit 0 for op2.

    assign signed_op1 = {{24{switches[15]}}, switches[15:8]};
    assign unsigned_op1 = {24'h00_0000, switches[15:8]};
    assign signed_op2 = {{24{switches[7]}}, switches[7:0]};
    assign unsigned_op2 = {24'h00_0000, switches[7:0]};

    always_comb begin
        mmio_regs[3] = op_comb[0] ? signed_op1 : unsigned_op1;
        mmio_regs[4] = op_comb[1] ? signed_op2 : unsigned_op2;
    end

    always_comb begin
        casez (testcase)
            4'b00??: op_comb = 2'b00;
            4'b010?: op_comb = 2'b00;
            4'b0110: op_comb = 2'b10;
            4'b0111: op_comb = 2'b00;
            4'b1000: op_comb = 2'b10;
            4'b10??: op_comb = 2'b00;
            4'b11??: op_comb = 2'b11;
        endcase
    end


    ///////////////////////////////////////////////////

    // source: 0x0014, Keypad
    always_comb begin
        mmio_regs[5] = 32'h0000_0000;
    end


    ///////////////////////////////////////////////////

    // MMIO Segment 1 - R/W enable

    ///////////////////////////////////////////////////

    // source: 0x0020, 0x0024, 0x0028, 0x002c, single LED indicator
    wire led_seg_wea_1;
    wire [3:0] led_wea_1;
    
    assign led_wea_1[0] = (wea && addr[15:0] == 16'h0020);
    assign led_wea_1[1] = (wea && addr[15:0] == 16'h0024);
    assign led_wea_1[2] = (wea && addr[15:0] == 16'h0028);
    assign led_wea_1[3] = (wea && addr[15:0] == 16'h002c);

    assign led[19] = mmio_regs[8] != 32'h0000_0000;
    assign led[18] = mmio_regs[9] != 32'h0000_0000;
    assign led[17] = mmio_regs[10] != 32'h0000_0000;
    assign led[16] = mmio_regs[11] != 32'h0000_0000;

    always_ff @(posedge data_clk, posedge rst) begin
        if (rst) begin
            mmio_regs[8] = 32'h0000_0000;
            mmio_regs[9] = 32'h0000_0000;
            mmio_regs[10] = 32'h0000_0000;
            mmio_regs[11] = 32'h0000_0000;
        end
        else begin
            mmio_regs[8] = led_wea_1[0] ? write_data : mmio_regs[8];
            mmio_regs[9] = led_wea_1[1] ? write_data : mmio_regs[9];
            mmio_regs[10] = led_wea_1[2] ? write_data : mmio_regs[10];
            mmio_regs[11] = led_wea_1[3] ? write_data : mmio_regs[11];
        end
    end


    ///////////////////////////////////////////////////

    // source: 0x0030, 0x0034 tube segment
    wire [31:0] tube_driver_in;
    wire [1:0] tube_wea;

    assign tube_driver_in = {mmio_regs[12][15:0], {mmio_regs[13][15:0]}};
    assign tube_wea[0] = (wea && addr[15:0] == 16'h0030);
    assign tube_wea[1] = (wea && addr[15:0] == 16'h0034);

    tube_driver tube_cont(.clk(dri_clk),
                          .rst(rst),
                          .in(tube_driver_in),
                          .tube_seg(tube_seg),
                          .tube_en(tube_en));

    always_ff @(posedge data_clk, posedge rst) begin
        if (rst) begin
            mmio_regs[12] = 32'h0000_0000;
            mmio_regs[13] = 32'h0000_0000;
        end
        else begin
            mmio_regs[12] = tube_wea[0] ? write_data : mmio_regs[12];
            mmio_regs[13] = tube_wea[1] ? write_data : mmio_regs[13];
        end
    end


    ///////////////////////////////////////////////////

    // source: 0x0038, 16 bit LED
    wire led_seg_wea_2;

    assign led_seg_wea_2 = (addr[15:0] == 16'h0038) && wea;
    assign led[15:0] = mmio_regs[14][15:0];

    always_ff @(posedge data_clk, posedge rst) begin
        if (rst) begin
            mmio_regs[14] = 32'h0000_0000;
        end
        else begin
            mmio_regs[14] = led_seg_wea_2 ? write_data : mmio_regs[14];
        end
    end


    ///////////////////////////////////////////////////

    // MMIO Segment 2

    ///////////////////////////////////////////////////

    // source: 0x0100 to 0x0a60, VGA text buffer
    wire vga_buf_wea;
    wire [31:0] vga_addr;
    wire [31:0] vga_write_data;
    wire [31:0] vga_read_data;

    assign is_in_mmio_seg_2 = addr[15:8] >= 8'h01 && addr[15:8] <= 8'h0a;
    assign vga_buf_wea = is_in_mmio_seg_2 && wea;
    assign vga_addr = is_in_mmio_seg_2 ? (addr - 32'h0000_0100) : 32'h0000_0000;
    assign vga_write_data = write_data;
    assign mmio_out_2 = vga_read_data;

    VGA_top vga_controller(.data_clk(data_clk),
                           .dri_clk(dri_clk),
                           .wea(vga_buf_wea),
                           .addr(vga_addr),
                           .write_data(vga_write_data),
                           .read_data(vga_read_data),
                           .red(vga_red),
                           .green(vga_green),
                           .blue(vga_blue),
                           .hsync(vga_hsync),
                           .vsync(vga_vsync));

endmodule