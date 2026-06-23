`timescale 1ns/1ps

module dFF #(
    parameter N = 1
) (
    input  wire [N-1:0] D,
    input  wire         clk, rst,
    output reg  [N-1:0] Y
);

    always @(posedge clk, posedge rst) begin
        if (rst) Y <= 0;
        else Y <= D;
    end
endmodule

module dReg #(
    parameter N = 1
) (
    input  wire [N-1:0] D,
    input  wire         clk, write_en,
    output reg  [N-1:0] Y
);

    always @(posedge clk) begin
        if (write_en) Y <= D;
    end

endmodule