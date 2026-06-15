`timescale 1ns / 1ps

module tb_adder;

    // Declare Inputs as registers (reg) and Outputs as wires
    reg [31:0] A;
    reg [31:0] B;
    reg add_sub;
    
    wire [31:0] sum;
    wire carry_out;
    wire zero;

    // Instantiate the Unit Under Test (UUT)
    adder uut (
        .A(A),
        .B(B),
        .add_sub(add_sub),
        .sum(sum),
        .carry_out(carry_out) // Connected to match your flattened module
    );

    // Recreate the zero flag locally in the testbench since the module dropped it
    assign zero = (sum == 32'b0);

    // Stimulus Block
    initial begin
        // Display header in the simulation console
        $display("Time\t\tA\t\tB\t\tadd_sub\tSum\t\tCOut\tZero");
        $display("------------------------------------------------------------------------------------");

        // Simple Addition No Carry
        A = 32'd5; B = 32'd3; add_sub = 1'b0;
        #10;
        assert_output(32'd8, 1'b0, 1'b0, "TC1: Simple Add Failed");

        // Simple Subtraction
        A = 32'd10; B = 32'd4; add_sub = 1'b1;
        #10;
        assert_output(32'd6, 1'b1, 1'b0, "TC2: Simple Sub Failed");

        // Result is Zero
        A = 32'd15; B = 32'd15; add_sub = 1'b1;
        #10;
        assert_output(32'd0, 1'b1, 1'b1, "TC3: Zero Flag Sub Failed");

        // Unsigned Overflow Addition
        A = 32'hFFFFFFFF; B = 32'd1; add_sub = 1'b0;
        #10;
        assert_output(32'd0, 1'b1, 1'b1, "TC4: Unsigned Overflow Add Failed");

        // Big Unsigned Addition
        A = 32'h80000000; B = 32'h80000000; add_sub = 1'b0;
        #10;
        assert_output(32'd0, 1'b1, 1'b1, "TC5: MSB Carry Add Failed");

        // Subtraction Borrow Required
        A = 32'd5; B = 32'd12; add_sub = 1'b1;
        #10;
        assert_output(-32'd7, 1'b0, 1'b0, "TC6: Negative Result Sub Failed");

        // Subtracting from Zero
        A = 32'd0; B = 32'd1; add_sub = 1'b1;
        #10;
        assert_output(32'hFFFFFFFF, 1'b0, 1'b0, "TC7: Underflow Sub Failed");

        // Block 0 to Block 1 Boundary Carry Test
        // Forces a carry to propagate exactly from bit 3 into bit 4
        A = 32'h0000000F; B = 32'h00000001; add_sub = 1'b0;
        #10;
        assert_output(32'h00000010, 1'b0, 1'b0, "TC8: Low Block Boundary Carry Failed");

        // Mid-Word Block Propagation Test
        // Sets bits 0 through 15 to all 1s, then adds 1 to make sure the lookahead 
        // logic correctly ripples the carry through Block 0, 1, 2, and 3 simultaneously.
        A = 32'h0000FFFF; B = 32'h00000001; add_sub = 1'b0;
        #10;
        assert_output(32'h00010000, 1'b0, 1'b0, "TC9: Multi-Block Propagate Failed");

        // Full Chain Propagate Worst-Case Delay Path
        // 0xFFFFFFFE + 1 = 0xFFFFFFFF (No Carry Out generated)
        A = 32'hFFFFFFFE; B = 32'h00000001; add_sub = 1'b0;
        #10;
        assert_output(32'hFFFFFFFF, 1'b0, 1'b0, "TC10: Full Chain Propagate Failed");

        // End Simulation
        $display("------------------------------------------------------------------------------------");
        $display("All checks completed successfully");
        $finish;
    end

    // Validation Helper Task
    task 
        assert_output(
        input [31:0] expected_sum, 
        input expected_carry, 
        input expected_zero, 
        input [8*35:1] msg
        );
        begin
            // Print current simulation state
            $display("%0t ns\t%h\t%h\t%b\t%h\t%b\t%b", $time, A, B, add_sub, sum, carry_out, zero);
            
            // Checking logic evaluating sum, carry_out, and the testbench-side zero flag
            if ((sum !== expected_sum) || (carry_out !== expected_carry) || (zero !== expected_zero)) begin
                $display("[ERROR] %s!", msg);
                $display("        Expected -> Sum: %h, COut: %b, Zero: %b", expected_sum, expected_carry, expected_zero);
                $display("        Got      -> Sum: %h, COut: %b, Zero: %b", sum, carry_out, zero);
                $stop; 
            end
        end
    endtask

endmodule