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

module dFF_en #(
    parameter N = 1
) (
    input  wire [N-1:0] D,     // data in
    input  wire         clk,   // clock
    input  wire         rst,   // reset → Y=0
    input  wire         en,    // 1=update, 0=hold
    output reg  [N-1:0] Y      // data out
);

    always @(posedge clk, posedge rst) begin
        if (rst)
            Y <= {N{1'b0}};
        else if (en)
            Y <= D;
        // Y holds previous value
    end

endmodule

module dReg #(
    parameter N = 1
) (
    input  wire [N-1:0] D,
    input  wire         clk,
    input  wire         rst,
    input  wire         write_en,
    output reg  [N-1:0] Y
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            Y <= {N{1'b0}};
        else if (write_en)
            Y <= D;
    end

endmodule