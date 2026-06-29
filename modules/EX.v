`timescale 1ns/1ps

module ALU (
    input  wire [31:0] in1, in2,
    input  wire        toggle,
    input  wire [ 2:0] sel,
    output wire [31:0] result
);

    wire [31:0] add_sub, sll, slt, sltu;
    wire [31:0] res_xor, srl_sra, res_or, res_and;

    adder X1 (
        .A(in1),
        .B(in2),
        .add_sub(toggle),
        .sum(add_sub)
    );

    lShift X2 (
        .X(in1),
        .shiftAmt(in2[4:0]),
        .SR(1'b0),
        .Y(sll)
    );

    assign slt = ($signed(in1) < $signed(in2)) ? 32'h0000_0001 : 32'b0;
    assign sltu = (in1 < in2) ? 32'h0000_0001 : 32'b0;

    assign res_xor = in1 ^ in2;

    rShift X3 (
        .X(in1),
        .shiftAmt(in2[4:0]),
        .SR(1'b0),
        .LA(toggle),
        .Y(srl_sra)
    );

    assign res_or = in1 | in2;
    assign res_and = in1 & in2;

    mux8 #(.N(32)) M_sel (
        .d0(add_sub), 
        .d1(sll), 
        .d2(slt), 
        .d3(sltu), 
        .d4(res_xor), 
        .d5(srl_sra), 
        .d6(res_or), 
        .d7(res_and),
        .sel(sel),
        .Y(result)
    );

endmodule

module EX (
    input  wire [31:0] rs1, rs2, PC,
    input  wire [31:0] imm_ext, imm20, // imm 20 is extended with 0s in LSB
    input  wire        is_I, f_toggle,
    input  wire [ 1:0] calc_type, // 0 = norm, 1 = JAL/JALR, 2 = AUIPC, 3 = LUI
    input  wire [ 2:0] func_sel,
    output wire [31:0] rd
);

    wire [31:0] in2, fin1, fin2;

    mux2 #(.N(32)) in2_select (
        .d0(rs2), .d1(imm_ext),
        .sel(is_I),
        .Y(in2)
    );

    mux4 #(.N(32)) fin1_select (
        .d0(rs1), 
        .d1(PC), 
        .d2(PC), 
        .d3(32'b0),
        .sel(calc_type),
        .Y(fin1)
    );

    mux4 #(.N(32)) fin2_select (
        .d0(in2), 
        .d1(32'h0000_0004), 
        .d2(imm20),
        .d3(imm20),
        .sel(calc_type),
        .Y(fin2)
    );

    ALU alu (
        .in1(fin1), .in2(fin2),
        .toggle(f_toggle),
        .sel(func_sel),
        .result(rd)
    );

endmodule