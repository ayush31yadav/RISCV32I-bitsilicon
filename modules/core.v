`timescale 1ns/1ps

module core (
    input  wire clk, rst
);

    wire [31:0] inst_if, pc_if;
    wire [31:0] inst_id, pc_id, pc_ex;

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

    // output reg         write_rd,
    // output wire [ 4:0] rd 
    // );

    wire [31:0] rs1_idex, rs2_idex, imm20_idex;
    wire [31:0] imm_ext_idex;
    wire        isI_idex, toggle_idex;
    wire [ 1:0] calc_type_idex;
    wire [ 2:0] func_sel_idex;

    wire        write_en_mem_idex, read_en_mem_idex;
    wire [ 1:0] write_size_mem_idex, read_size_mem_idex;
    wire        read_us_mem_idex;

    wire        write_rd_idex;
    wire [ 4:0] rd_idex;

    wire [31:0] rs1_ex, rs2_ex, imm20_ex;
    wire [31:0] imm_ext_ex;
    wire        isI_ex, toggle_ex;
    wire [ 1:0] calc_type_ex;
    wire [ 2:0] func_sel_ex;

    wire        write_en_mem_ex, read_en_mem_ex;
    wire [ 1:0] write_size_mem_ex, read_size_mem_ex;
    wire        read_us_mem_ex;
    
    wire        write_rd_ex;
    wire [ 4:0] rd_ex;

    wire [31:0] new_val_rd;
    wire        write_en_rd;
    wire [ 4:0] write_to_rd;

    ID inst_decode (
        .clk(clk),
        .inst(inst_id),
        .data_write(new_val_rd),
        .write_en(write_en_rd),
        .write_to(write_to_rd),

        .rs1_if(rs1_idif),
        .imm_if(imm_idif),
        .pc_sel_specType(sType_idif), .pc_sel_isSpec(iSpec_idif),
        // EXEC
        .rs1_ex(rs1_idex), .rs2_ex(rs2_idex), .imm20_ex(imm20_idex),
        .imm_ext_ex(imm_ext_idex),
        .isI_ex(isI_idex), .toggle_ex(toggle_idex),
        .calc_type_ex(calc_type_idex),
        .func_sel_ex(func_sel_idex),
        // MEM
        .write_en_mem(write_en_mem_idex), .read_en_mem(read_en_mem_idex),
        .write_size_mem(write_size_mem_idex), .read_size_mem(read_size_mem_idex),
        .read_us_mem(read_us_mem_idex),
        // GEN
        .write_rd(write_rd_idex),
        .rd(rd_idex)
    );

    dFF #(.N(119)) pip_idex (
        .D({pc_id, rs1_idex, rs2_idex, imm20_idex, imm_ext_idex, isI_idex, toggle_idex,
        calc_type_idex, func_sel_idex, write_en_mem_idex, read_en_mem_idex, write_size_mem_idex,
        read_size_mem_idex, read_us_mem_idex, write_rd_idex, rd_idex}),
        .clk(clk), .rst(rst),
        .Y({pc_ex, rs1_ex, rs2_ex, imm20_ex, imm_ext_ex, isI_ex, toggle_ex,
        calc_type_ex, func_sel_ex, write_en_mem_ex, read_en_mem_ex, write_size_mem_ex,
        read_size_mem_ex, read_us_mem_ex, write_rd_ex, rd_ex})
    );

    wire [31:0] rd_val;

    EX execute (
        .rs1(rs1_ex), .rs2(rs2_ex), .PC(pc_ex),
        .imm_ext(imm_ext_ex), .imm20(imm20_ex),
        .is_I(isI_ex), .f_toggle(toggle_ex),
        .calc_type(calc_type_ex),
        .func_sel(func_sel_ex),
        .rd(rd_val)
    );

    wire [31:0] rd_val_m;
    wire        write_en_mem, read_en_mem;
    wire [ 1:0] write_size_mem, read_size_mem;
    wire        read_us_mem, write_rd_mem;
    wire [ 4:0] rd_mem;
    wire [31:0] rs2_mem;

    dFF #(.N(77)) pip_exmem (
        .D({rd_val, write_en_mem_ex, read_en_mem_ex, write_size_mem_ex, read_size_mem_ex,
        read_us_mem_ex, write_rd_ex, rd_ex, rs2_ex}),
        .clk(clk), .rst(rst),
        .Y({rd_val_m, write_en_mem, read_en_mem, write_size_mem, read_size_mem,
        read_us_mem, write_rd_mem, rd_mem, rs2_mem})
    );

    wire [31:0] mem_read_val;

    memory mem (
        .clk(clk), .rst(rst),
        .wr_en(write_en_mem),
        .rd_en(read_en_mem),
        .write_size(write_size_mem),
        .read_size(read_size_mem),
        .read_us(read_us_mem),

        .wr_addr(rd_val_m),
        .rd_addr(rd_val_m),

        .data_write(rs2_mem),
        .data_read(mem_read_val)
    );

    wire        read_en_mem_wb, write_rd_wb;
    wire [31:0] rd_val_wb, mem_read_wb;
    wire [ 4:0] rd_wb;

    dFF #(.N(102)) pip_memwb (
        .D({read_en_mem, rd_val_m, write_rd_mem, rd_mem, mem_read_val}),
        .clk(clk), .rst(rst),
        .Y({read_en_mem_wb, rd_val_wb, write_rd_wb, rd_wb, mem_read_wb})
    );

    mux2 #(.N(32)) rd_select (
        .d0(rd_val_wb),
        .d1(mem_read_wb),
        .sel(read_en_mem_wb),
        .Y(new_val_rd)
    );

    assign write_en_rd = read_en_mem_wb | write_rd_wb;
    assign write_to_rd = rd_wb;

endmodule