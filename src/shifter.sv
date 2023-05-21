`timescale 1ns/1ps

module shifter(
    input  wire [31:0] d,
    input  wire [4:0]  shamt,
    input  wire dir,          // if asserted, shift right
    input  wire ari,          // if asserted, do arithmetic shift

    output reg  [31:0] q
    );

    reg [31:0] s_res; // result of shift

    always_comb begin
        if (dir) begin
            s_res = d >> shamt;
        end
        else begin
            s_res = d << shamt;
        end
    end

    always_comb begin
        if (dir && ari) begin
            q = {d[31], s_res[30:0]};
        end
        else begin
            q = s_res;
        end
    end

endmodule