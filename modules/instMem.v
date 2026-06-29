`timescale 1ns/1ps

// instruction memory
module instMem (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    // assign inst = {addr[31:2], 2'b00};

    always @(*) begin
        case (addr)
            32'h0000_0000 : inst <= 32'h0000_60B7; // LUI 6 to X1           X1 = 0060 0000
            32'h0000_0004 : inst <= 32'h0000_6117; // AUIPC 6 to X2         X2 = 0060 0004
            32'h0000_0008 : inst <= 32'h00A0_0193; // ADDI 10 to X0         X3 = 0000 000A
            32'h0000_000c : inst <= 32'h00A0_0213; // ADDI 10 to X0         X4 = 0000 000A
            32'h0000_0010 : inst <= 32'h00B0_0293; // ADDI 10 to X0         X5 = 0000 000B
            32'h0000_0014 : inst <= 32'h0000_0000; // NOP
            32'h0000_0018 : inst <= 32'h0000_0000; // NOP
            32'h0000_001c : inst <= 32'h0041_8333; // ADD X3, X4 = X6       X6 = 0000 0014
            default :       inst <= {addr[31:2], 2'b00};
        endcase
    end

endmodule