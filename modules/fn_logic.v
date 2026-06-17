`timescale 1ns/1ps


//          opCode   funct3
// XOR   R  0110011  100
// OR    R  0110011  101
// AND   R  0110011  111
// XORI  I  0010011  100
// ORI   I  0010011  101
// ANDI  I  0010011  111
module fn_logic (
    input  wire [31:0] rs1, rs2,
    input  wire [31:0] imm,        // bit shifted
    input  wire  [2:0] funct3,
    input  wire        opCode5,
    output wire [31:0] result
);

    wire [31:0] v2;

    mux2 #(.N(32)) imm_select (
        .d0(imm), .d1(rs2),
        .sel(opCode5),
        .Y(v2)
    );

    mux4 #(.N(32)) logic_select (
        .d0(rs1 ^ v2), 
        .d1(rs1 | v2), 
        .d2(32'b0), 
        .d3(rs1 & v2),
        .sel(funct3[1:0]),
        .Y(result)
    );

endmodule