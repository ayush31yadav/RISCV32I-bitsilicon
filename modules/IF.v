`timescale 1ns/1ps

module IF (
    input  wire        clk, rst,
    input  wire [31:0] rs1_id, imm_id, imm12_id,
    input  wire [ 1:0] pc_inc_select,
    output wire [31:0] inst, pc          // PC for JAL, JALR intructions
);

    wire [31:0] pc_inc_mux, pc_inc_sub, new_pc;

    mux4 #(.N(32)) inc_mux (
        .d0(32'h0000_0004), 
        .d1(imm_id), 
        .d2(rs1_id + imm_id), 
        .d3(imm12_id),
        .sel(pc_inc_select),
        .Y(pc_inc_mux)
    );

    assign pc_inc_sub = (|pc_inc_select) ? pc_inc_mux - 32'h0000_0004 : pc_inc_mux;
    assign new_pc = pc + pc_inc_sub;

    dFF #(.N(32)) pc_reg (
        .D(new_pc),
        .clk(clk), .rst(rst),
        .Y(pc)
    );

    instMem im (
        .addr(pc),
        .inst(inst)
    );

endmodule