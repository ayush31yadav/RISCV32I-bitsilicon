`timescale 1ns/1ps

// instruction memory
module instMem (
    input  wire [31:0] addr,
    output wire [31:0] inst
);

    assign inst = {addr[31:2], 2'b00};

endmodule