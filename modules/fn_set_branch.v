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
// BEQ    B
// BNE    B
// BLT    B
// BGE    B
// BLTU   B
// BGEU   B

module fn_setUnit (
    input  wire [31:0] rs1, rs2,
    input  wire [11:0] imm12,     // used for I
    input  wire        opCode5,   // determines if R or I
    input  wire        funct3_0,  // if signed(0) or unsigned(1)
    output wire [31:0] result
);

    wire [31:0] imm32;
    wire extending_bit;

    mux2 #(.N(1)) sign_extend (
        .d0(imm12[11]), .d1(1'b0),
        .sel(funct3_0),
        .Y(extending_bit)
    );

    assign imm32 = {{20{extending_bit}}, imm12};

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

    
    mux2 #(.N(1)) re_select (
        .d0(LS), .d1(LU),
        .sel(funct3_0),
        .Y(result)
    );

endmodule

module fn_branchUnit (

);


endmodule