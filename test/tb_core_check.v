`timescale 1ns/1ps
// Drop-in replacement for tb_core.v's final block:
// checks the architected result of the self-checking program already
// baked into instMem.v, and counts stall/forward events.

module tb_core_check;
    reg clk, rst;
    integer stall_count, fwdA_count, fwdB_count;
    integer errors;

    core uut (.clk(clk), .rst(rst));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        stall_count = 0;
        fwdA_count  = 0;
        fwdB_count  = 0;
        errors      = 0;

        rst = 1;
        #12 rst = 0;
        #800;

        // ---- architected-state check ----
        check(1,  32'd5,  "x1 = 5 (ADDI baseline)");
        check(2,  32'd7,  "x2 = 7 (ADDI baseline)");
        check(3,  32'd12, "x3 = 12 (ADD x1+x2)");
        check(4,  32'd7,  "x4 = 7  (SUB x3-x1, EX->EX forward)");
        check(5,  32'd14, "x5 = 14 (ADD x4+x4, MEM->EX forward)");
        check(6,  32'd14, "x6 = 14 (LW from M[0])");
        check(7,  32'd26, "x7 = 26 (ADD x6+x3, load-use stall)");
        check(8,  32'd1,  "x8 = 1  (ADDI baseline)");
        check(9,  32'd0,  "x9 = 0  (must be FLUSHED, branch taken)");
        check(11, 32'd48,  "x11 = 48 (JAL link value at branch target)");
        check(12, 32'd0,  "x12 = 0 (must be FLUSHED, jumped over)");

        $display("=================================================");
        $display("Stall events observed  : %0d (expect >= 2: 1 load-use + 1 ctrl)", stall_count);
        $display("ForwardA events observed: %0d", fwdA_count);
        $display("ForwardB events observed: %0d", fwdB_count);
        if (fwdA_count == 0 && fwdB_count == 0)
            $display("WARNING: forwarding never fired -- check ID/EX wiring");
        $display("=================================================");
        if (errors == 0)
            $display("RESULT: ALL CHECKS PASSED");
        else
            $display("RESULT: %0d CHECK(S) FAILED", errors);

        $finish;
    end

    task check(input integer regnum, input [31:0] expected, input [127:0] label);
        reg [31:0] actual;
        begin
            actual = uut.inst_decode.rF.r_out[regnum];
            if (actual !== expected) begin
                $display("FAIL: %0s -- got 0x%08h, expected 0x%08h", label, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", label);
            end
        end
    endtask

    always @(posedge clk) if (!rst && uut.stall)    stall_count = stall_count + 1;
    always @(posedge clk) if (!rst && uut.forwardA != 2'b00) fwdA_count = fwdA_count + 1;
    always @(posedge clk) if (!rst && uut.forwardB != 2'b00) fwdB_count = fwdB_count + 1;

endmodule