`timescale 1ns/1ps

module top (
    input  wire clk,
    input  wire rst,
    input  wire mode_switch,     // switch between UART comm mode and CPU load mode

    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    // TODO: add other IO devices
    );

    // debounce for rst
    reg rst_ctrl;  // real rst signal
    reg [1:0] cnt;
    always_ff @(posedge clk) begin
        if (rst) begin
            rst_ctrl <= 1'b1;
            cnt <= 2'b00;
        end
        else begin
            if (cnt == 2'b11) begin
                cnt <= 2'b00;
                rst_ctrl <= 1'b0;
            end
            else begin
                cnt <= cnt + 2'b01;
            end
        end
    end


    // clk_ctrl
    wire cpu_clk;
    reg cpu_en;
    reg cpu_rst;

    clk_wiz_0 clk_gen(.clk_in1(clk),
                      .clk_out1(cpu_clk),
                      .clk_out2(uart_clk));
//    assign CPU_clk = clk;
    assign CPU_en = 1;    // todo: switch between UART mode and other.

    wire overflow;

    wire mem_write;
    wire [31:0] instr_addr, instr, mem_addr, write_data;
    reg  [31:0] read_data;
    
    CPU CPU_inst(.clk(CPU_clk),
                 .rst(rst_ctrl),
                 .en(CPU_en),
                 .instr_addr(instr_addr),
                 .instr(instr),
                 .mem_write(mem_write),
                 .mem_addr(mem_addr),
                 .write_data(write_data),
                 .read_data(read_data),
                 .overflow(overflow));
    

    // set instruction memory
    wire [31:0] true_instr_addr;
    
    assign true_instr_addr = $signed(instr_addr) - $signed(32'h0040_0000);
                 
    instr_mem instr_memory(.clka(cpu_clk),
                           .addra(true_instr_addr[15:2]),
                           .wea(0),
                           .dina(0),
                           .douta(instr));
    

    // set MMIO
    wire is_in_MMIO_seg;
    wire [31:0] MMIO_addr;
    wire MMIO_wea;
    wire [31:0] MMIO_out;

    assign is_in_MMIO_seg = (mem_addr >= 32'hffff_0000 && mem_addr <= 32'hffff_0080);
    assign MMIO_addr = is_in_MMIO_seg ? (mem_addr - 32'h1000_0000) : 32'h0000_0000; // map to address starting at 0x0
    assign MMIO_wea = is_in_MMIO_seg && mem_write;

    // setup IO connections
    MMIO_cont MMIO_controller(.clk(~cpu_clk),
                              .rst(rst_ctrl),
                              .addr(MMIO_addr),
                              .write_data(write_data),
                              .read_data(MMIO_out),
                              .wea(MMIO_wea),
                              .mode(mode),
                              .overflow(overflow),
                              .buttons(buttons),
                              .switches(switches),
                              .led(led),
                              .tube_en(tube_en),
                              .tube_seg(tube_seg)); // TODO: add other IO devices

    
    // set data memory
    wire is_in_data_seg;
    wire [31:0] data_addr;
    wire data_wea;
    wire [31:0] data_out;
    
    assign is_in_data_seg = (mem_addr >= 32'h1001_0000 && mem_addr < 32'h7000_0000);
    assign data_addr = is_in_data_seg ? (mem_addr - 32'h1001_0000) : 32'h0000_0000; // map to address starting at 0x0
    assign data_wea = is_in_data_seg && mem_write;
    
    data_mem data_memory(.clka(~cpu_clk),
                         .addra(data_addr[15:2]),
                         .dina(write_data),
                         .douta(data_out),
                         .wea(data_wea));
    

    // set stack memory
    wire is_in_stack_seg;
    wire [31:0] stack_addr;
    wire stack_wea;
    wire [31:0] stack_out;
    
    assign is_in_stack_seg = (mem_addr >= 32'h7000_0000 && mem_addr <= 32'h7fff_effc);
    assign stack_addr = is_in_stack_seg  ? (32'h7fff_effc - mem_addr) : 32'h0000_0000; // map to address starting at 0x0
    assign stack_wea = is_in_stack_seg  && mem_write;
    
    stack_mem stack_memory(.clka(~cpu_clk),
                           .addra(stack_addr[15:2]),
                           .dina(write_data),
                           .douta(stack_out),
                           .wea(stack_wea));
    

    // set the source of read_data
    wire [1:0] data_dst;
    
    assign data_dst = {is_in_data_seg, is_in_stack_seg, is_in_MMIO_seg};
    
    // adjust read port
    always_comb begin
        casez (data_dst)
            3'b100: read_data = data_out;
            3'b010: read_data = stack_out;
            3'b001: read_data = MMIO_out;
            default: read_data = 32'h0000_0000;
        endcase
    end
    
endmodule
