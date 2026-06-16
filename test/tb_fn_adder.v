`timescale 1ns / 1ps

module tb_fn_adder;

    reg  [31:0] A, B, PC;
    reg  [11:0] imm12;
    reg  [19:0] imm20;
    reg         op2;
    reg         op5;
    reg         funct7_5;

    wire [31:0] sum;

    fn_adder DUT (
        .A(A),
        .B(B),
        .PC(PC),
        .imm12(imm12),
        .imm20(imm20),
        .op2(op2),
        .op5(op5),
        .funct7_5(funct7_5),
        .sum(sum)
    );

    initial begin

        // -------------------------
        // ADD : 25 + 15 = 40
        // opcode = 0110011
        // -------------------------
        A        = 32'd25;
        B        = 32'd15;
        PC       = 32'd0;
        imm12    = 12'd0;
        imm20    = 20'd0;
        op2      = 1'b0;
        op5      = 1'b1;
        funct7_5 = 1'b0;

        #10;
        $display("ADD   : sum=%0d (expected 40)", sum);

        // -------------------------
        // SUB : 25 - 15 = 10
        // opcode = 0110011
        // funct7[5] = 1
        // -------------------------
        funct7_5 = 1'b1;

        #10;
        $display("SUB   : sum=%0d (expected 10)", sum);

        // -------------------------
        // ADDI : 100 + (-4) = 96
        // opcode = 0010011
        // -------------------------
        A        = 32'd100;
        imm12    = 12'hFFC;    // -4
        op2      = 1'b0;
        op5      = 1'b0;
        funct7_5 = 1'b0;

        #10;
        $display("ADDI  : sum=%0d (expected 96)", $signed(sum));

        // -------------------------
        // AUIPC : PC + (1 << 12)
        // opcode = 0010111
        // -------------------------
        PC       = 32'h00001000;
        imm20    = 20'h00001;
        op2      = 1'b1;
        op5      = 1'b0;
        funct7_5 = 1'b0;

        #10;
        $display("AUIPC : sum=0x%08h (expected 0x00002000)", sum);

        // -------------------------
        // AUIPC with larger offset
        // PC + (0x12345 << 12)
        // -------------------------
        PC       = 32'h10000000;
        imm20    = 20'h12345;

        #10;
        $display("AUIPC : sum=0x%08h", sum);

        $finish;
    end

endmodule