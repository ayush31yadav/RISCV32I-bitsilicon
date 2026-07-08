`timescale 1ns/1ps

// instruction memory
module instMem (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    // assign inst = {addr[31:2], 2'b00};

    always @(*) begin
        case (addr)
            32'h0000_0000 : inst <= 32'h0000_60B7; // LUI 6 to X1                    X1 = 0000 6000
            32'h0000_0004 : inst <= 32'h0000_6117; // AUIPC 6 to X2                  X2 = 0060 0004
            32'h0000_0008 : inst <= 32'h00A0_0193; // ADDI 10 to X0                  X3 = 0000 000A
            32'h0000_000c : inst <= 32'h00A0_0213; // ADDI 10 to X0                  X4 = 0000 000A
            32'h0000_0010 : inst <= 32'h00B0_0293; // ADDI 10 to X0                  X5 = 0000 000B
            32'h0000_0014 : inst <= 32'h0000_0000; // NOP         
            32'h0000_0018 : inst <= 32'h0000_0000; // NOP         
            32'h0000_001c : inst <= 32'h0041_8333; // ADD X3, X4 = X6                X6 = 0000 0014
            32'h0000_0020 : inst <= 32'h0010_2023; // STORE X1 at M[0]    
            32'h0000_0024 : inst <= 32'h0020_1423; // STORE X2[15:0] at M[8]    
            32'h0000_0028 : inst <= 32'h0000_0000; // NOP    
            32'h0000_002c : inst <= 32'h0000_0000; // NOP    
            32'h0000_0030 : inst <= 32'h0000_2383; // LOAD M[0] word to X7           X7 = 0000 6000
            32'h0000_0034 : inst <= 32'h0041_8A63; // JMP to 0048 using BEQ X3, X4
            32'h0000_0038 : inst <= 32'h0000_0000; // NOP
            32'h0000_003c : inst <= 32'h0000_0000; // NOP
            32'h0000_0040 : inst <= 32'h0000_0000; // NOP
            32'h0000_0044 : inst <= 32'h0000_0000; // NOP
            32'h0000_0048 : inst <= 32'h0080_046F; // JAL X8,  PC += 8               X8 = 0000 004c
            32'h0000_004c : inst <= 32'h0000_0000; // NOP
            32'h0000_0050 : inst <= 32'hFB00_04E7; // JALR X9, PC += -50
            default :       inst <= {addr[31:2], 2'b00};
        endcase
    end

endmodule