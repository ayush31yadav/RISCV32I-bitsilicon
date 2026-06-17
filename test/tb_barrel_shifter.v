// tb_barrel_shifter.v
// Self-checking testbench for the logarithmic barrel shifter
// Covers SLL, SRL, SRA, edge cases (shift 0/31), sign extension, and fallback behavior.

`timescale 1ns / 1ps

module tb_barrel_shifter;

  reg  [31:0] data_in;
  reg  [4:0]  shift_amount;
  reg  [2:0]  funct3;
  reg  [6:0]  funct7;
  wire [31:0] data_out;

  // DUT
  barrel_shifter dut (
    .data_in     (data_in),
    .shift_amount(shift_amount),
    .funct3      (funct3),
    .funct7      (funct7),
    .data_out    (data_out)
  );

  integer errors = 0;
  integer tests  = 0;

// Helper task - Changed from SystemVerilog string to standard Verilog reg array
  task check;
    input [31:0] expected;
    input [399:0] name; // 50 characters * 8 bits = 400 bits total capacity
    begin
      tests = tests + 1;
      #1;  // let combo logic settle
      if (data_out !== expected) begin
        $display("FAIL: %-40s  got=0x%08h  expected=0x%08h", name, data_out, expected);
        errors = errors + 1;
      end else begin
        $display("PASS: %-40s  0x%08h", name, data_out);
      end
    end
  endtask

  initial begin
    $display("================================================================");
    $display("  Barrel Shifter (SLL/SRL/SRA) - Logarithmic MUX Layer Test");
    $display("================================================================\n");

    // --------------------------------------------------------------------
    // SLL (funct3 = 001)
    // --------------------------------------------------------------------
    funct3 = 3'b001;
    funct7 = 7'b0000000; // don't care for SLL

    // shift 0
    data_in = 32'h12345678; shift_amount = 5'd0;
    check(32'h12345678, "SLL sh=0 (identity)");

    // basic
    data_in = 32'h00000001; shift_amount = 5'd1;
    check(32'h00000002, "SLL 0x1 << 1");

    data_in = 32'h00000001; shift_amount = 5'd4;
    check(32'h00000010, "SLL 0x1 << 4");

    // max shift
    data_in = 32'h00000001; shift_amount = 5'd31;
    check(32'h80000000, "SLL 0x1 << 31");

    // shift through sign bit
    data_in = 32'h40000000; shift_amount = 5'd2;
    check(32'h00000000, "SLL 0x40000000 << 2 (overflow)");

    data_in = 32'h00000003; shift_amount = 5'd30;
    check(32'hC0000000, "SLL 0x3 << 30");

    // --------------------------------------------------------------------
    // SRL (funct3 = 101, funct7[5]=0)
    // --------------------------------------------------------------------
    funct3 = 3'b101;
    funct7 = 7'b0000000;   // SRL

    data_in = 32'h80000000; shift_amount = 5'd1;
    check(32'h40000000, "SRL 0x80000000 >> 1 (logical)");

    data_in = 32'h80000000; shift_amount = 5'd31;
    check(32'h00000001, "SRL 0x80000000 >> 31 (logical)");

    data_in = 32'hFFFFFFFF; shift_amount = 5'd8;
    check(32'h00FFFFFF, "SRL 0xFFFFFFFF >> 8");

    data_in = 32'h12345678; shift_amount = 5'd0;
    check(32'h12345678, "SRL sh=0 (identity)");

    // other bits in funct7 should be ignored (only [5] matters)
    funct7 = 7'b0001010;  // [5]=0 (SRL), other bits noisy
    data_in = 32'hF0000000; shift_amount = 5'd4;
    check(32'h0F000000, "SRL with noisy funct7 (still SRL)");

    // --------------------------------------------------------------------
    // SRA (funct3 = 101, funct7[5]=1)
    // --------------------------------------------------------------------
    funct3 = 3'b101;
    funct7 = 7'b0100000;   // SRA (bit 30 / [5] = 1)

    data_in = 32'h80000000; shift_amount = 5'd1;
    check(32'hC0000000, "SRA 0x80000000 >> 1 (arith sign ext)");

    data_in = 32'h80000000; shift_amount = 5'd31;
    check(32'hFFFFFFFF, "SRA 0x80000000 >> 31 (all sign bits)");

    data_in = 32'h7FFFFFFF; shift_amount = 5'd4;   // positive
    check(32'h07FFFFFF, "SRA positive 0x7FFF... >> 4 (same as logical)");

    data_in = 32'hF0000000; shift_amount = 5'd8;
    check(32'hFFF00000, "SRA 0xF0000000 >> 8 (arith)");

    // shift 0 for SRA
    data_in = 32'h80000000; shift_amount = 5'd0;
    check(32'h80000000, "SRA sh=0 (identity, sign preserved)");

    // noisy funct7, only [5] should matter
    funct7 = 7'b0101111;  // [5]=1
    data_in = 32'h80000F00; shift_amount = 5'd12;
    check(32'hFFF80000, "SRA noisy funct7 (still SRA)");

    // --------------------------------------------------------------------
    // Fallback / safety cases (invalid funct3)
    // --------------------------------------------------------------------
    funct3 = 3'b000;  // ADD or other - should produce 0 per our safe default
    funct7 = 7'b0000000;
    data_in = 32'hDEADBEEF; shift_amount = 5'd7;
    check(32'h00000000, "INVALID funct3=000 -> safe 0");

    funct3 = 3'b010;
    data_in = 32'h12345678; shift_amount = 5'd3;
    check(32'h00000000, "INVALID funct3=010 -> safe 0");

    funct3 = 3'b111;
    check(32'h00000000, "INVALID funct3=111 -> safe 0");

    // --------------------------------------------------------------------
    // Summary
    // --------------------------------------------------------------------
    $display("\n================================================================");
    if (errors == 0) begin
      $display("  ALL %0d TESTS PASSED", tests);
    end else begin
      $display("  %0d FAILURES OUT OF %0d TESTS", errors, tests);
    end
    $display("================================================================\n");

    $finish;
  end

endmodule
