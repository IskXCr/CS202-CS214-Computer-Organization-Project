`timescale 1ns/1ps

module top (
    input  wire clk,
    input  wire rst,
    input  wire uart_trigger,
    input  wire work_trigger,

    input  wire upg_rx_i,
    output wire upg_tx_o,

    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    // TODO: add other IO devices
    );


    // rst_ctrl, debounce
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


    // mode_ctrl
    // uart_trigger and work_trigger
    reg mode_ctrl; // 1 if WORK mode
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            mode_ctrl <= 1'b0;
        end
        else begin
            if (work_trigger)
                mode_ctrl <= 1'b1;
            else if (uart_trigger)
                mode_ctrl <= 1'b0;
            else
                mode_ctrl <=  mode_ctrl;
        end
    end


    // clk_ctrl
    wire cpu_clk;
    wire uart_clk;

    clk_wiz_0 clk_gen(.clk_in1(clk),
                      .clk_out1(cpu_clk),
                      .clk_out2(uart_clk));


    // setup UART
    wire [13:0] uart_write_addr;
    wire [31:0] uart_write_data;
    wire uart_write_target;      // 0 for instruction, 1 for memory
    // TODO: change this
    assign uart_write_addr = 32'b0000_0000;
    assign uart_write_target = 32'b0000_0000;
    // assign uart
    wire uart_write_clk;
    wire uart_wen;
    wire uart_done;

    uart_bmpg_0 uart_controller(.upg_clk_i(uart_clk),
                                .upg_rst_i(rst_ctrl),
                                .upg_clk_o(uart_clk),
                                .upg_wen_o(uart_wen),
                                .upg_adr_o({uart_write_target, uart_write_addr}),
                                .upg_dat_o(uart_write_data),
                                .upg_done_o(uart_done),
                                .upg_rx_i(upg_rx_i),
                                .upg_tx_o(upg_tx_o));


    // set CPU
    wire cpu_en;
    wire cpu_rst;
    assign cpu_en = mode_ctrl;
    assign cpu_rst = rst_ctrl;

    wire overflow;

    wire cpu_mem_write;
    wire [31:0] cpu_instr_addr, cpu_instr, cpu_mem_addr, cpu_write_data;
    reg  [31:0] cpu_read_data;
    
    CPU CPU_inst(.clk(cpu_clk),
                 .rst(rst_ctrl),
                 .en(CPU_en),
                 .instr_addr(cpu_instr_addr),
                 .instr(cpu_instr),
                 .mem_write(cpu_mem_write),
                 .mem_addr(cpu_mem_addr),
                 .write_data(cpu_write_data),
                 .read_data(cpu_read_data),
                 .overflow(overflow));
    

    // set instruction memory
    wire instr_clk;
    wire [31:0] true_instr_addr;
    wire [31:0] instr_write_data;
    wire instr_wea;
    
    assign instr_clk = (~mode_ctrl & ~uart_write_clk) | (mode_ctrl & ~cpu_clk);
    assign true_instr_addr = mode_ctrl ? (cpu_instr_addr - 32'h0040_0000) : uart_write_addr;
    assign instr_write_data = uart_write_data;
    assign instr_wea = (~mode_ctrl & ~uart_write_target & uart_wen);
    
                 
    instr_mem instr_memory(.clka(instr_clk),
                           .addra(true_instr_addr[15:2]),
                           .dina(instr_write_data),
                           .douta(cpu_instr),
                           .wea(instr_wea));

    
    // set data memory
    wire data_clk;
    wire is_in_data_seg;
    wire [31:0] data_addr;
    wire [31:0] data_out;
    wire data_wea;
    
    assign data_clk = (~mode_ctrl & ~uart_write_clk) | (mode_ctrl & ~cpu_clk);
    assign is_in_data_seg = (cpu_mem_addr >= 32'h1001_0000 && cpu_mem_addr < 32'h7000_0000);
    assign data_addr = mode_ctrl ? (is_in_data_seg ? (cpu_mem_addr - 32'h1001_0000) : 32'h0000_0000) : uart_write_addr ; // map to address starting at 0x0
    assign data_wea = mode_ctrl ? (is_in_data_seg && cpu_mem_write) : (uart_write_target & uart_wen);
    
    data_mem data_memory(.clka(data_clk),
                         .addra(data_addr[15:2]),
                         .dina(cpu_write_data),
                         .douta(data_out),
                         .wea(data_wea));
    

    // set stack memory
    wire is_in_stack_seg;
    wire [31:0] stack_addr;
    wire stack_wea;
    wire [31:0] stack_out;
    
    assign is_in_stack_seg = (cpu_mem_addr >= 32'h7000_0000 && cpu_mem_addr <= 32'h7fff_effc);
    assign stack_addr = is_in_stack_seg  ? (32'h7fff_effc - cpu_mem_addr) : 32'h0000_0000; // map to address starting at 0x0
    assign stack_wea = is_in_stack_seg  && cpu_mem_write;
    
    stack_mem stack_memory(.clka(~cpu_clk),
                           .addra(stack_addr[15:2]),
                           .dina(cpu_write_data),
                           .douta(stack_out),
                           .wea(stack_wea));


    // set MMIO
    wire is_in_MMIO_seg;
    wire [31:0] MMIO_addr;
    wire MMIO_wea;
    wire [31:0] MMIO_out;

    assign is_in_MMIO_seg = (cpu_mem_addr >= 32'hffff_0000 && cpu_mem_addr <= 32'hffff_0080);
    assign MMIO_addr = is_in_MMIO_seg ? (cpu_mem_addr - 32'h1000_0000) : 32'h0000_0000; // map to address starting at 0x0
    assign MMIO_wea = is_in_MMIO_seg && cpu_mem_write;

    MMIO_cont MMIO_controller(.cpu_clk(~cpu_clk),
                              .dri_clk(clk),
                              .rst(rst_ctrl),
                              .addr(MMIO_addr),
                              .write_data(cpu_write_data),
                              .read_data(MMIO_out),
                              .wea(MMIO_wea),
                              .mode(mode_ctrl),
                              .overflow(overflow),
                              .buttons(buttons),
                              .switches(switches),
                              .led(led),
                              .tube_en(tube_en),
                              .tube_seg(tube_seg)); // TODO: add other IO devices


    // set the source of cpu_read_data
    wire [1:0] data_dst;
    
    assign data_dst = {is_in_data_seg, is_in_stack_seg, is_in_MMIO_seg};
    
    // adjust read port
    always_comb begin
        casez (data_dst)
            3'b100: cpu_read_data = data_out;
            3'b010: cpu_read_data = stack_out;
            3'b001: cpu_read_data = MMIO_out;
            default: cpu_read_data = 32'h0000_0000;
        endcase
    end
    
endmodule
