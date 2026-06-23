`timescale 1ns/1ps

module core (
    input  wire clk, rst
);

    wire [31:0] inst_if, pc_if;

    IF inst_fetch (
        .clk(clk), .rst(rst),
        .rs1_id(),
        .imm_id(),
        .imm12_id(),
        .pc_inc_select(2'b00),
        .inst(inst_if), .pc(pc_if)
    );

endmodule