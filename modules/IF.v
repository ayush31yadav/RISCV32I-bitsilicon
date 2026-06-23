`timescale 1ns/1ps

module IF (
    input  wire        clk, rst,
    input  wire [31:0] rs1_id, imm_id,
    input  wire        spec_type, is_spec,
    output wire [31:0] inst, pc          // PC for JAL, JALR intructions
);

    wire [31:0] spec_add, inst_pre, add_amt;
    wire [5:0] new_op;

    mux2 #(.N(32)) spec_sel (
        .d0(imm_id), .d1(rs1_id + imm_id),
        .sel(spec_type),
        .Y(spec_add)
    );

    mux2 #(.N(32)) type_sel (
        .d0(32'h0000_0004), .d1(spec_add - 32'h0000_0004),
        .sel(is_spec),
        .Y(add_amt)
    );

    dFF #(.N(32)) pc_reg (
        .D(pc + add_amt),
        .clk(clk), .rst(rst),
        .Y(pc)
    );

    instMem im (
        .addr(pc),
        .inst(inst_pre)
    );
    
    mux2 #(.N(6)) op_sel (
        .d0(inst_pre[31:26]), .d1(6'b0),
        .sel(is_spec),
        .Y(new_op)
    );

    assign inst = {new_op, inst_pre[25:0]};

endmodule