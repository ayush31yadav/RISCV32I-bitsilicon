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
        rst <= 1;
        #10 rst <= 0;
        #50 $finish;
    end

endmodule