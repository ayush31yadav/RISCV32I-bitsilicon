`timescale 1ns/1ps

// instructions to implement
// SET instructions set a value to the destinations register thus they are 
// part of the EXE unit while the BRANCH instructions can be implemented earlier
// thus two different modules
//            opCode    funct3
// SLT    R   0110011   010       rs1 < rs2
// SLTU   R   0110011   011       rs1 < rs2 U
// SLTI   I   0010011   010       rs1 < imm
// SLTIU  I   0010011   011       rs1 < imm U
// ---------------------------------------
// BEQ    B             000
// BNE    B             001
// BLT    B             100
// BGE    B             101
// BLTU   B             110
// BGEU   B             111

module fn_setUnit (
    input  wire [31:0] rs1, rs2,
    input  wire [31:0] imm32,     // used for I, extended input
    input  wire        opCode5,   // determines if R or I
    input  wire        funct3_0,  // if signed(0) or unsigned(1)
    output wire [31:0] result
);

    wire [31:0] v2;

    mux2 #(.N(32)) imm_select (
        .d0(imm32), .d1(rs2),
        .sel(opCode5),
        .Y(v2)
    );

    wire LS, LU;

    comparator C (
        .A(rs1),
        .B(v2),
        .LS(LS),
        .LU(LU)
    );

    wire res;
    
    mux2 #(.N(1)) res_select (
        .d0(LS), .d1(LU),
        .sel(funct3_0),
        .Y(res)
    );

    assign result = {31'b0, res};

endmodule

module fn_branchUnit (
    input  wire [31:0] rs1, rs2,
    input  wire  [2:0] funct3,
    output wire        branch // 1 is BRANCH TAKEN
);

    wire LS, LU, EQ;

    comparator C (
        .A(rs1),
        .B(rs2),
        .LS(LS),
        .LU(LU),
        .EQ(EQ)
    );
    
    mux8 #(.N(1)) result_select (
        .d0(EQ), 
        .d1(~EQ), 
        .d2(1'b0), 
        .d3(1'b0), 
        .d4(LS), 
        .d5(~LS), 
        .d6(LU), 
        .d7(~LU),
        .sel(funct3),
        .Y(branch)
    );

endmodule