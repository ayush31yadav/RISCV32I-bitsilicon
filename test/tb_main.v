`timescale 1ns/1ps

module tb_main;

    reg clk, rst;

    core uut (
        .clk(clk), .rst(rst)
    );

    initial begin
        forever #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        #100 $finish;
    end

endmodule