`timescale 1ns / 1ps

module tb_adder;

    // Declare inputs and outputs
    reg [31:0] A;
    reg [31:0] B;
    reg add_sub;
    
    wire [31:0] sum;
    wire carry_out;
    wire zero;

    // Instantiate Unit under test
    adder uut (
        .A(A),
        .B(B),
        .add_sub(add_sub),
        .sum(sum),
        .carry_out(carry_out), // <--- Connected the new port
        .zero(zero)
    );

    // Stimulus
    initial begin
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

        // End Simulation
        $display("------------------------------------------------------------------------------------");
        $display("All tests completed successfully!");
        $finish;
    end

    // Display results
    task 
        assert_output(
        input [31:0] expected_sum, 
        input expected_carry, 
        input expected_zero, 
        input [8*35:1] msg
    );
        begin
            $display("%0t ns\t%h\t%h\t%b\t%h\t%b\t%b", $time, A, B, add_sub, sum, carry_out, zero);
            
            if ((sum !== expected_sum) || (carry_out !== expected_carry) || (zero !== expected_zero)) begin
                $display("[ERROR] %s!", msg);
                $display("        Expected -> Sum: %h, COut: %b, Zero: %b", expected_sum, expected_carry, expected_zero);
                $display("        Got      -> Sum: %h, COut: %b, Zero: %b", sum, carry_out, zero);
                $stop;
            end
        end
    endtask

endmodule