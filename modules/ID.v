`timescale 1ns/1ps

module ID (
    input  wire [31:0] inst, pc,
    output wire [31:0] rs1_if, imm_if,
    output wire        pc_sel_specType, pc_sel_isSpec
);
    // in base instruction set and also M extension the last two bits of
    // of opCode are 11

    // ====================================
    // BRANCH, PC modifications control
    // ====================================

    // BRANCH on 1100011 imm
    // JAL       1101111 imm
    // JALR      1100111 rs1+imm

    wire isBranch, isJAL, isJALR;

    assign isBranch = (inst[31:27] == 5'b11000);
    assign isJAL    = (inst[31:27] == 5'b11011);
    assign isJALR   = (inst[31:27] == 5'b11001);

    assign pc_sel_isSpec = (isBranch | isJAL | isJALR);
    assign pc_sel_specType = isJALR;

    // ====================================

endmodule