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
    input  wire uart_done,
    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    );
    // address conversion
    wire [3:0] read_addr;
    assign real_addr = addr[5:2];

    // MMIO out configuration
    reg  [31:0] mmio_regs [0:15];
    wire [31:0] mmio_out  [0:15];
    
    assign mmio_out = mmio_regs;
    assign read_data = mmio_out[real_addr];


    // assign MMIO memory
    // source: 0x0004, scenario switch
    wire [4:0] testcase;

    assign testcase[4] = switches[23];

    always_comb begin
        mmio_regs[1] = {31'h0000_0000, testcase[4]};
    end

    // source: 0x0008, testcase number
    assign testcase[3:0] = switches[22:20];

    always_comb begin
        mmio_regs[2] = {29'h0000_0000, testcase[3:0]};
    end

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

    // source: 0x0014, Keypad
    always_comb begin
        mmio_regs[5] = 32'h0000_0000;
    end

    // source: 0x0020, 0x0024, 0x0028, 0x002c, single LED indicator
    wire led_seg_wea_1;
    wire [3:0] led_wea_1;
    
    assign led_seg_wea_1 = (addr[7:4] == 4'b0010) && wea;
    assign led_wea_1[0] = (led_seg_wea_1 && addr[3:2] == 2'b00);
    assign led_wea_1[1] = (led_seg_wea_1 && addr[3:2] == 2'b01);
    assign led_wea_1[2] = (led_seg_wea_1 && addr[3:2] == 2'b10);
    assign led_wea_1[3] = (led_seg_wea_1 && addr[3:2] == 2'b11);

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

    // source: 0x0030, 0x0034 LED segment
    wire [31:0] tube_driver_in;
    wire tube_seg_wea;
    wire [1:0] tube_wea;

    assign tube_driver_in = {mmio_regs[12][15:0], {mmio_regs[13][15:0]}};
    assign tube_seg_wea = (addr[7:4] == 4'b0011) && wea;
    assign tube_wea[0] = (tube_seg_wea && addr[3:2] == 2'b00);
    assign tube_wea[1] = (tube_seg_wea && addr[3:2] == 2'b01);

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

    // source: 0x0038, 16 bit LED
    wire led_seg_wea_2;

    assign led_seg_wea_2 = (addr[7:2] == 6'b00_1110) && wea;
    assign led[15:0] = mmio_regs[14][15:0];

    always_ff @(posedge data_clk, posedge rst) begin
        if (rst) begin
            mmio_regs[14] = 32'h0000_0000;
        end
        else begin
            mmio_regs[14] = led_seg_wea_2 ? write_data : mmio_regs[14];
        end
    end

    // configure other directedly mapped IOs
    assign led[23] = mode;
    assign led[22] = uart_done;

endmodule