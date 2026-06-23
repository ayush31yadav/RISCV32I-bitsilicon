`timescale 1ns/1ps

module core (
    input  wire clk, rst
);

    wire [31:0] inst_if, pc_if;
    wire [31:0] inst_id, pc_id;

    wire [31:0] rs1_idif, imm_idif;
    wire        sType_idif, iSpec_idif;

    IF inst_fetch (
        .clk(clk), .rst(rst),
        .rs1_id(rs1_idif),
        .imm_id(imm_idif),
        .spec_type(sType_idif), 
        .is_spec(iSpec_idif),
        .inst(inst_if), .pc(pc_if)
    );

    dFF #(.N(64)) pip_ifid (
        .D({inst_if, pc_if}),
        .clk(clk), .rst(rst),
        .Y({inst_id, pc_id})
    );

    ID inst_decode (
        .inst(inst_id), .pc(pc_id),
        .rs1_if(rs1_idif), .imm_if(imm_idif),
        .pc_sel_specType(sType_idif), .pc_sel_isSpec(iSpec_idif)
    );

endmodule