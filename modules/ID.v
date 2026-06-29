`timescale 1ns/1ps

module ID (
    input  wire        clk,
    input  wire [31:0] inst,
    input  wire [31:0] data_write,
    input  wire        write_en,
    input  wire [ 4:0] write_to,
    // instruction fetch
    output wire [31:0] rs1_if, 
    output reg  [31:0] imm_if,
    output reg         pc_sel_specType, pc_sel_isSpec,
    // EXEC
    output wire [31:0] rs1_ex, rs2_ex, imm20_ex,
    output reg  [31:0] imm_ext_ex,
    output reg         isI_ex, toggle_ex,
    output reg  [ 1:0] calc_type_ex,
    output reg  [ 2:0] func_sel_ex,
    // MEM
    output reg         write_en_mem, read_en_mem,
    output wire [ 1:0] write_size_mem, read_size_mem,
    output wire        read_us_mem,
    // GEN
    output reg         write_rd,
    output wire [ 4:0] rd 
);
    // in base instruction set and also M extension the last two bits of
    // of opCode are 11

    // ====================================
    // regFile
    // ====================================

    wire [31:0] rs1, rs2;
    wire        isBranch;

    regFile rF (
        .data_write(data_write),
        .reg_read_1(inst[19:15]), 
        .reg_read_2(inst[24:20]), 
        .reg_write(write_to),
        .clk(~clk),
        .write_en(write_en),
        .data_read1(rs1), .data_read2(rs2) 
    );

    fn_branchUnit f_bU (
        .rs1(rs1), .rs2(rs2),
        .funct3(inst[14:12]),
        .branch(isBranch)
    );

    // ====================================
    // decoder
    // ====================================

    assign rs1_if = rs1;
    assign rs1_ex = rs1;
    assign rs2_ex = rs2;

    wire [6:0] opCode;
    assign opCode = inst[6:0];
    assign imm20_ex = {inst[31:12], 20'b0};
    assign rd = inst[11:7];
    assign read_size_mem = inst[13:12];
    assign write_size_mem = inst[13:12];
    assign read_us_mem = inst[14];

    always @(*) begin
        case (opCode)
            7'b0110011 : begin
                // R calc
                isI_ex <= 1'b0;
                toggle_ex <= inst[30];
                calc_type_ex <= 2'b0;
                func_sel_ex <= inst[14:12];
                write_rd <= 1'b1;
                // ---
                pc_sel_isSpec <= 1'b0;
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
            end
            7'b0010011 : begin
                // I calc
                isI_ex <= 1'b1;
                toggle_ex <= inst[30];
                calc_type_ex <= 2'b0;
                func_sel_ex <= inst[14:12];
                imm_ext_ex <= {{20{inst[31]}}, inst[31:20]};
                write_rd <= 1'b1;
                // ---
                pc_sel_isSpec <= 1'b0;
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
            end
            7'b0000011 : begin
                // load
                read_en_mem <= 1'b1;
                imm_ext_ex <= {{20{inst[31]}}, inst[31:20]};
                // addr gen
                isI_ex <= 1'b1;
                calc_type_ex <= 2'b0;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                // ---
                pc_sel_isSpec <= 1'b0;
                write_en_mem <= 1'b0;
                write_rd = 1'b0;
            end
            7'b0100011 : begin
                // store
                write_en_mem <= 1'b1;
                imm_ext_ex <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
                // addr gen
                isI_ex <= 1'b1;
                calc_type_ex <= 2'b0;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                // ---
                pc_sel_isSpec <= 1'b0;
                read_en_mem <= 1'b0;
                write_rd = 1'b0;
            end
            7'b1100011 : begin
                // branch
                imm_if <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                pc_sel_isSpec <= isBranch;
                pc_sel_specType <= 1'b0;
                // ---
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
                write_rd <= 1'b0;
            end
            7'b1101111 : begin
                // JAL
                pc_sel_isSpec <= 1'b1;
                pc_sel_specType <= 1'b0;
                imm_if <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

                isI_ex <= 1'b0;
                calc_type_ex <= 2'b01;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                write_rd <= 1'b1;
                // ---
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
            end
            7'b1100111 : begin
                // JALR
                pc_sel_isSpec <= 1'b1;
                pc_sel_specType <= 1'b1;
                imm_if <= {{20{inst[31]}}, inst[31:20]};

                isI_ex <= 1'b0;
                calc_type_ex <= 2'b01;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                write_rd <= 1'b1;
                // ---
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
            end
            7'b0110111 : begin
                // LUI
                isI_ex <= 1'b0;
                calc_type_ex <= 2'b11;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                write_rd <= 1'b1;
                // ---
                pc_sel_isSpec <= 1'b0;
            end
            7'b0010111 : begin
                // AUIPC
                isI_ex <= 1'b0;
                calc_type_ex <= 2'b10;
                func_sel_ex <= 3'b000;
                toggle_ex <= 1'b0;
                write_rd <= 1'b1;
                // ---
                pc_sel_isSpec <= 1'b0;
            end
            7'b0000000 : begin
                // NULL
                write_en_mem <= 1'b0;
                read_en_mem <= 1'b0;
                write_rd <= 1'b0;
                pc_sel_isSpec <= 1'b0;
            end
        endcase
    end


endmodule