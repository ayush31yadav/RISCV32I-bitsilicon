`timescale 1ns/1ps

module tb_core;

    reg clk, rst;

    core uut (
        .clk(clk), .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #300 $finish;
    end

endmodule