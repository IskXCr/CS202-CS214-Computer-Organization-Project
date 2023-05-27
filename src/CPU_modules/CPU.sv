`timescale 1ns/1ps

module CPU #(parameter TEXT_BASE_ADDR = 32'h0040_0000) (
    input  wire clk,
    input  wire rst,
    
    input  wire cpu_en, // async enable. This enable signal will be processed by the next clock cycle.

    output wire [31:0] instr_addr,
    input  wire [31:0] instr,

    output wire mem_write,
    output wire [31:0] mem_addr,
    output wire [31:0] write_data,
    input  wire [31:0] read_data,

    output wire overflow
    );

    // delay enable write. Only after fetching the correct instruction will it start to process.
    // delay 2 clock cycle.
    reg en_delay_cnt;
    reg en;
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            en_delay_cnt <= 1'b0;
            en <= 1'b0;     
        end
        else begin
            if (cpu_en) begin
                if (en_delay_cnt == 1'b1) begin
                    en <= 1'b1;
                    en_delay_cnt <= 1'b1;
                end
                else begin
                    en <= 1'b0;
                    en_delay_cnt <= en_delay_cnt + 1'b1;
                end
            end
            else begin
                en <= 1'b0;
                en_delay_cnt <= 1'b0;
            end
        end
    end

    wire [31:0] pc4;
    wire instr_jump, instr_branch, jump_dst;
    wire cont_branch;
    wire branch_comp_zero;

    // Register
    wire rwe, dmem_we;  // register write enabled, dmemory write enabled
    wire ALU_src;      // ALU_src
    wire use_sign_imm; // use signed immediate
    wire reg_pc4_src;  // use pc4 as the source of write data for link instrutions
    wire [15:0] imm_16;
    wire [31:0] sign_imm, unsigned_imm, imm;
    
    assign imm_16 = instr[15:0];
    assign sign_imm = {{16{imm_16[15]}}, imm_16};
    assign unsigned_imm = {16'd0, imm_16};

    wire [1:0] reg_dst;
    wire [4:0] rt, rd, ra, rwaddr, rraddr2; // rwd for register write address
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    wire [31:0] rwdata, rrdata1, rrdata2, rwdata1;

    // ALU
    wire [31:0] ALU_op1, ALU_op2, ALU_out;
    wire [3:0] ALU_control;
    wire [4:0] shamt;
    wire shift_src, shift_dir, shift_ari, do_unsigned, ALU_reg_write, ALU_reg_sel;

    wire ALU_lt, ALU_eq, ALU_overflow;
    assign overflow = ALU_overflow;

    wire mem_to_reg;

    // cpu_en_ctrl
    wire instr_ctrl_en, reg_ctrl_en, dmem_ctrl_en;
    assign instr_ctrl_en = en && ~rst;
    assign reg_ctrl_en = en && ~rst && rwe ;
    assign dmem_ctrl_en = en && ~rst && dmem_we;
    
    // inst_cont
    instr_cont #(TEXT_BASE_ADDR) instr_controller(.clk(clk),
                                                  .rst(rst),
                                                  .en(instr_ctrl_en),
                                                  .pc4(pc4),
                                                  .instr_addr(instr_addr),
                                                  .instr(instr[25:0]),
                                                  .rjump_addr(rrdata1),
                                                  .jump(instr_jump),
                                                  .jump_dst(jump_dst),
                                                  .branch(instr_branch));
    
    // branch_cont
    branch_cont branch_controller(.cont_branch(cont_branch),
                                  .op(instr[31:26]),
                                  .link(instr[20:16]),
                                  .ALU_lt(ALU_lt),
                                  .ALU_eq(ALU_eq),
                                  .branch(instr_branch));

    // controller part
    main_dec main_decoder(.op(instr[31:26]),
                          .rt_msb(instr[20]),
                          .funct(instr[5:0]),
                          .mem_to_reg(mem_to_reg),
                          .mem_write(dmem_we),
                          .branch(cont_branch),
                          .branch_comp_zero(branch_comp_zero),
                          .reg_write(rwe),
                          .reg_dst(reg_dst),
                          .reg_pc4_src(reg_pc4_src),
                          .jump(instr_jump),
                          .jump_dst(jump_dst));

    ALU_dec ALU_decoder(.ALU_op(instr[31:26]),
                        .funct(instr[5:0]),
                        .shift_src(shift_src),
                        .shift_dir(shift_dir),
                        .shift_ari(shift_ari),
                        .do_unsigned(do_unsigned),
                        .ALU_src(ALU_src),
                        .use_sign_imm(use_sign_imm),
                        .ALU_reg_write(ALU_reg_write),
                        .ALU_reg_sel(ALU_reg_sel),
                        .ALU_control(ALU_control));

    // register part
    assign ra = 5'b11111;

    mux2 imm_sign_mux(.d0(unsigned_imm), 
                      .d1(sign_imm),
                      .sel(use_sign_imm),
                      .q(imm));

    mux2 #(5) reg_rdata2_mux(.d0(instr[20:16]),
                             .d1(5'b00000),
                             .sel(branch_comp_zero),
                             .q(rraddr2));

    mux3 #(5) reg_waddr_mux(.d0(rt),
                            .d1(rd),
                            .d2(ra),
                            .sel(reg_dst),
                            .q(rwaddr));

    mux2 reg_wdata_mux(.d0(rwdata1),
                       .d1(pc4),
                       .sel(reg_pc4_src), 
                       .q(rwdata));
  
    reg_file registers(.clk(clk),
                       .rst(rst),
                       .we(reg_ctrl_en),
                       .ra1(instr[25:21]), 
                       .ra2(rraddr2),
                       .wa(rwaddr),
                       .wd(rwdata), 
                       .rd1(rrdata1),
                       .rd2(rrdata2));

    // ALU part
    assign ALU_op1 = rrdata1;

    mux2 ALU_op2_mux(.d0(rrdata2),
                     .d1(imm),
                     .sel(ALU_src),
                     .q(ALU_op2));
    
    mux2 #(5) ALU_shift_mux(.d0(instr[10:6]), 
                            .d1(ALU_op1[4:0]),
                            .sel(shift_src),
                            .q(shamt));

    ALU ALU_inst(.clk(clk),
                 .rst(rst),
                 .ALU_control(ALU_control), 
                 .shamt(shamt),
                 .shift_dir(shift_dir),
                 .shift_ari(shift_ari),
                 .do_unsigned(do_unsigned),
                 .ALU_reg_write(ALU_reg_write),
                 .ALU_reg_sel(ALU_reg_sel),
                 .op_1(ALU_op1),
                 .op_2(ALU_op2),
                 .ALU_eq(ALU_eq),
                 .ALU_lt(ALU_lt),
                 .overflow(ALU_overflow),
                 .ALU_out(ALU_out));

    // data memory
    wire [31:0] dmem_wdata, dmem_addr;
    assign dmem_wdata = rrdata2;
    assign dmem_addr = ALU_out;

    assign mem_write = dmem_ctrl_en;
    assign mem_addr = dmem_addr;
    assign write_data = dmem_wdata;

    mux2 mem2reg_mux(.d0(ALU_out),
                     .d1(read_data),
                     .sel(mem_to_reg),
                     .q(rwdata1));

endmodule