`timescale 1ns/1ps
module instMem (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    always @(*) begin
        case (addr)
        // 32'h0000_0000 : inst <= 32'h0000_60B7; // LUI 6 to X1                    X1 = 0000 6000
        //     32'h0000_0004 : inst <= 32'h0000_6117; // AUIPC 6 to X2                  X2 = 0060 0004
        //     32'h0000_0008 : inst <= 32'h00A0_0193; // ADDI 10 to X0                  X3 = 0000 000A
        //     32'h0000_000c : inst <= 32'h00A0_0213; // ADDI 10 to X0                  X4 = 0000 000A
        //     32'h0000_0010 : inst <= 32'h00B0_0293; // ADDI 10 to X0                  X5 = 0000 000B
        //     32'h0000_0014 : inst <= 32'h0000_0000; // NOP         
        //     32'h0000_0018 : inst <= 32'h0000_0000; // NOP         
        //     32'h0000_001c : inst <= 32'h0041_8333; // ADD X3, X4 = X6                X6 = 0000 0014
        //     32'h0000_0020 : inst <= 32'h0010_2023; // STORE X1 at M[0]    
        //     32'h0000_0024 : inst <= 32'h0020_1423; // STORE X2[15:0] at M[8]    
        //     32'h0000_0028 : inst <= 32'h0000_0000; // NOP    
        //     32'h0000_002c : inst <= 32'h0000_0000; // NOP    
        //     32'h0000_0030 : inst <= 32'h0000_2383; // LOAD M[0] word to X7           X7 = 0000 6000
        //     32'h0000_0034 : inst <= 32'h0041_8A63; // JMP to 0048 using BEQ X3, X4
        //     32'h0000_0038 : inst <= 32'h0000_0000; // NOP
        //     32'h0000_003c : inst <= 32'h0000_0000; // NOP
        //     32'h0000_0040 : inst <= 32'h0000_0000; // NOP
        //     32'h0000_0044 : inst <= 32'h0000_0000; // NOP
        //     32'h0000_0048 : inst <= 32'h0080_046F; // JAL X8,  PC += 8               X8 = 0000 004c
        //     32'h0000_004c : inst <= 32'h0000_0000; // NOP
        //     32'h0000_0050 : inst <= 32'hFB00_04E7; // JALR X9, PC += -50
    //Hazard test 
    32'h0000_0000 : inst <= 32'h00500093; // ADDI x1,x0,5
    32'h0000_0004 : inst <= 32'h00700113; // ADDI x2,x0,7

    32'h0000_0008 : inst <= 32'h002081B3; // ADD  x3,x1,x2      (12)
    32'h0000_000C : inst <= 32'h40118233; // SUB  x4,x3,x1      (7)  EX->EX forward
    32'h0000_0010 : inst <= 32'h004202B3; // ADD  x5,x4,x4      (14) MEM->EX forward

    32'h0000_0014 : inst <= 32'h00502023; // SW   x5,0(x0)
    32'h0000_0018 : inst <= 32'h00002303; // LW   x6,0(x0)

    32'h0000_001C : inst <= 32'h003303B3; // ADD  x7,x6,x3      (26) requires stall

    32'h0000_0020 : inst <= 32'h00100413; // ADDI x8,x0,1
    32'h0000_0024 : inst <= 32'h00840463; // BEQ  x8,x8,+8

    32'h0000_0028 : inst <= 32'h06300493; // ADDI x9,x0,99

    32'h0000_002C : inst <= 32'h008005EF; // JAL  x11,+8

    32'h0000_0030 : inst <= 32'h04D00613; // ADDI x12,x0,77

     32'h0000_0034 : inst <= 32'h0000006F; // END: JAL x0,0
 
    
default : inst <= 32'h00000013; 
     endcase
    end

endmodule
