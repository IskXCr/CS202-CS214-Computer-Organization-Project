`timescale 1ns/1ps

module top (
    input  wire fpga_clk,

    input  wire upg_rx_i,
    output wire upg_tx_o,

    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    // TODO: add other IO devices
    );

    wire rst_ctrl;
    assign rst_ctrl = buttons[4];

    // mode_ctrl
    // uart_trigger and work_trigger
    wire uart_trigger, work_trigger; // if pressed, switch to corresponding mode
    assign uart_trigger = buttons[3];
    assign work_trigger = buttons[2];

    reg mode_ctrl = 1'b1; // 1 if WORK mode

//    initial begin
//        mode_ctrl <= 1'b1;
//    end

    always_ff @(negedge fpga_clk, posedge rst_ctrl) begin
        if (rst_ctrl) begin
            mode_ctrl <= 1'b1;
        end
        else begin
            if (work_trigger) begin
                mode_ctrl <= 1'b1;
            end
            else if (uart_trigger) begin
                mode_ctrl <= 1'b0;
            end
            else begin
                mode_ctrl <= mode_ctrl;
            end
        end
    end


    // clk_ctrl
    wire new_clk;
    wire cpu_clk;
    wire uart_clk;

    assign cpu_clk = new_clk;
    assign uart_clk = new_clk;

    clk_wiz_0 clk_gen(.clk_in1(fpga_clk),
                      .reset(1'b0),
//                     .locked(1'b0),
                      .clk_out1(new_clk));

    // assign cpu_clk = clk;
    // assign uart_clk = clk;


    // setup UART
    reg  uart_rst;
    wire [13:0] uart_write_addr;
    wire [31:0] uart_write_data;
    wire uart_write_target;      // 0 for instruction, 1 for memory
    // assign uart
    wire uart_write_clk;
    wire uart_wen, uart_wen_o;
    wire uart_done;
    BUFG bufg(.I(uart_wen_o), .O(uart_wen));

    always_ff @(posedge fpga_clk, posedge rst_ctrl) begin
        if (rst_ctrl) begin
            uart_rst <= 1'b1;
        end
        else begin
            if (mode_ctrl) begin
                uart_rst <= 1'b1;
            end
            else begin
                uart_rst <= 1'b0;
            end
        end
    end

    uart_bmpg_0 uart_controller(.upg_clk_i(uart_clk),
                                .upg_rst_i(uart_rst),
                                .upg_clk_o(uart_write_clk),
                                .upg_wen_o(uart_wen_o),
                                .upg_adr_o({uart_write_target, uart_write_addr}),
                                .upg_dat_o(uart_write_data),
                                .upg_done_o(uart_done),
                                .upg_rx_i(upg_rx_i),
                                .upg_tx_o(upg_tx_o));


    // set CPU
    reg cpu_en;
    reg cpu_rst;
    reg [31:0] cpu_en_cnt;

    always_ff @(posedge fpga_clk, posedge rst_ctrl) begin
        if (rst_ctrl) begin
            cpu_en <= 1'b0;
            cpu_rst <= 1'b1;
            cpu_en_cnt <= 0;
        end
        else begin
            if (mode_ctrl) begin
                if (cpu_en == 1'b0) begin
                    if (cpu_en_cnt == 32'h0000_00ff) begin
                        cpu_en <= 1'b1;
                        cpu_rst <= 1'b0;
                        cpu_en_cnt <= cpu_en_cnt;
                    end
                    else begin
                        cpu_en <= 1'b0;
                        cpu_rst <= 1'b0;
                        cpu_en_cnt <= cpu_en_cnt + 1;
                    end
                end
                else begin
                    cpu_en <= 1'b1;
                    cpu_rst <= 1'b0;
                    cpu_en_cnt <= 0;
                end
            end
            else begin
                cpu_en <= 1'b0;
                cpu_rst <= 1'b1;
                cpu_en_cnt <= 0;
            end
        end
    end

    wire overflow;

    wire cpu_mem_write;
    wire [31:0] cpu_instr_addr, cpu_instr, cpu_mem_addr, cpu_write_data;
    reg  [31:0] cpu_read_data;
    
    CPU CPU_inst(.clk(cpu_clk),
                 .rst(cpu_rst),
                 .cpu_en(cpu_en),
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
    
    assign instr_clk = mode_ctrl ? cpu_clk : uart_write_clk;
    assign true_instr_addr = mode_ctrl ? (cpu_instr_addr - 32'h0040_0000) : {16'h0000, uart_write_addr, 2'b00};
    assign instr_write_data = uart_write_data;
    assign instr_wea = (~mode_ctrl && ~uart_write_target && uart_wen);
    
                 
    instr_mem instr_memory(.clka(instr_clk),
                           .addra(true_instr_addr[15:2]),
                           .dina(instr_write_data),
                           .douta(cpu_instr),
                           .wea(instr_wea));

    
    // set data memory
    wire data_clk;
    wire is_in_data_seg;
    wire [31:0] data_addr;
    wire [31:0] data_write_data;
    wire [31:0] data_out;
    wire data_wea;
    
    assign data_clk = mode_ctrl ? ~cpu_clk : uart_write_clk;
    assign is_in_data_seg = (cpu_mem_addr >= 32'h1001_0000 && cpu_mem_addr < 32'h1002_0000);
    assign data_addr = mode_ctrl ? (is_in_data_seg ? (cpu_mem_addr - 32'h1001_0000) : 32'h0000_0000) : {16'h0000, uart_write_addr, 2'b00}; // map to address starting at 0x0
    assign data_write_data = mode_ctrl ? cpu_write_data : uart_write_data;
    assign data_wea = mode_ctrl ? (is_in_data_seg && cpu_mem_write) : (uart_write_target && uart_wen);
    
    data_mem data_memory(.clka(data_clk),
                         .addra(data_addr[15:2]),
                         .dina(data_write_data),
                         .douta(data_out),
                         .wea(data_wea));
    

    // set stack memory
    wire is_in_stack_seg;
    wire [31:0] stack_addr;
    wire stack_wea;
    wire [31:0] stack_out;
    
    assign is_in_stack_seg = (cpu_mem_addr >= 32'h7ffe_effc && cpu_mem_addr <= 32'h7fff_effc);
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
    assign MMIO_addr = is_in_MMIO_seg ? (cpu_mem_addr - 32'hffff_0000) : 32'h0000_0000; // map to address starting at 0x0
    assign MMIO_wea = is_in_MMIO_seg && cpu_mem_write;

    MMIO_cont MMIO_controller(.data_clk(~cpu_clk),
                              .dri_clk(fpga_clk),
                              .rst(cpu_rst),
                              .addr(MMIO_addr),
                              .write_data(cpu_write_data),
                              .read_data(MMIO_out),
                              .wea(MMIO_wea),
                              .mode(mode_ctrl),
                              .overflow(overflow),
                              .instr_wen(instr_wea),
                              .data_wen(data_wea),
                              .uart_done(uart_done),
                              .buttons(buttons),
                              .switches(switches),
                              .led(led),
                              .tube_en(tube_en),
                              .tube_seg(tube_seg)); // TODO: add other IO devices


    // set the source of cpu_read_data
    wire [2:0] data_dst;
    
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
