`timescale 1ns/1ps

// instruction memory
module instMem (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    // assign inst = {addr[31:2], 2'b00};

    always @(*) begin
        case (addr)
            32'h0000_0000 : inst <= 32'h0000_60B7;
            default :       inst <= {addr[31:2], 2'b00};
        endcase
    end

endmodule