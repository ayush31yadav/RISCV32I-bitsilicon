`timescale 1ns/1ps

module IF (
    input  wire        clk, rst,
    input  wire        stall,           
    input  wire [31:0] rs1_id, imm_id,
    input  wire        spec_type, is_spec,
    output wire [31:0] inst, pc
);

    wire [31:0] spec_add, inst_pre, add_amt;

    mux2 #(.N(32)) spec_sel (
        .d0(imm_id),
        .d1(rs1_id + imm_id),
        .sel(spec_type),
        .Y(spec_add)
    );

    mux2 #(.N(32)) type_sel (
        .d0(32'h0000_0004),
        .d1(spec_add - 32'h0000_0004),
        .sel(is_spec),
        .Y(add_amt)
    );

    // PC: update only when NOT stalling
    dFF_en #(.N(32)) pc_reg (
        .D(pc + add_amt),
        .clk(clk),
        .rst(rst),
        .en(~stall),      // stall=1 → en=0 → HOLD pc
        .Y(pc)
    );

    instMem im (
        .addr(pc),
        .inst(inst_pre)
    );

    wire [6:0] new_op;

    mux2 #(.N(7)) op_sel (
        .d0(inst_pre[6:0]),
        .d1(7'b0),
        .sel(is_spec),
        .Y(new_op)
    );

    assign inst = {inst_pre[31:7], new_op};

endmodule