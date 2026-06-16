`timescale 1ns / 1ps

// fn_adder = final adder
//          OPCODE    funct7
//   ADD    0110011   000_0000    A+B
//   SUB    0110011   010_0000    A-B
//  ADDI    0010011               A+imm12
// AUIPC    0010111               PC+imm20
module fn_adder (
    input  wire [31:0] A, B, PC,
    input  wire [11:0] imm12,
    input  wire [19:0] imm20,
    input  wire        op2,          // OPCODE[2]
    input  wire        op5,          // OPCODE[5]
    input  wire        funct7_5,     // funct7[5]
    output wire [31:0] sum
);

    wire [31:0] v1, v2, imm;
    wire isSub;

    assign isSub = (op5 & funct7_5);  // 1 = Subtract, 0 = Add

    mux2 #(.N(32)) imm_select (
        .d0({{20{imm12[11]}}, imm12}), .d1({imm20, 12'b0}),
        .sel(op2),
        .Y(imm)
    );
    
    mux2 #(.N(32)) v1_select (
        .d0(A), .d1(PC),
        .sel(op2),
        .Y(v1)
    );

    mux2 #(.N(32)) v2_select (
        .d0(imm), .d1(B),
        .sel(op5),
        .Y(v2)
    );

    adder add(
        .A(v1),
        .B(v2),
        .add_sub(isSub),   // 0 = Add, 1 = Subtract
        .sum(sum)
    );

endmodule