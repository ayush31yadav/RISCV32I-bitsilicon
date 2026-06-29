`timescale 1ns / 1ps

module tb_comparator();

// Declare inputs as reg and outputs as wire
reg [31:0] A;
reg [31:0] B;
wire LS;
wire LU;
wire EQ;

// Error tracking counter
integer errors = 0;

// Instantiate Dut
comparator dut (
    .A(A), 
	.B(B),
    .LS(LS),          
    .LU(LU),          
    .EQ(EQ)           
);

// Stimulus
initial 
	begin
        $display("Time\t A (Hex)     B (Hex)     EQ      LU       LS");
        $display("---------------------------------------------------------------------");

        // Equal
        A = 32'hA5A5_5A5A; B = 32'hA5A5_5A5A;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b1 || LU !== 1'b0 || LS !== 1'b0) errors = errors + 1;

        // Zero and Equal
        A = 32'h0000_0000; B = 32'h0000_0000;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b1 || LU !== 1'b0 || LS !== 1'b0) errors = errors + 1;

        // Unsigned Less Than
        A = 32'h0000_0005; B = 32'h0000_000A;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b1 || LS !== 1'b1) errors = errors + 1;

        // Unsigned Greater Than
        A = 32'h0000_0020; B = 32'h0000_000F;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b0 || LS !== 1'b0) errors = errors + 1;

        // Signed and Unsigned
        A = 32'hFFFF_FFFF; B = 32'h0000_0001;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b0 || LS !== 1'b1) errors = errors + 1;

        // Unsigned and Signed
        A = 32'h0000_0001; B = 32'hFFFF_FFFF;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b1 || LS !== 1'b0) errors = errors + 1;

        // Both Negative
        A = 32'hFFFF_FFFE; B = 32'hFFFF_FFFF;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b1 || LS !== 1'b1) errors = errors + 1;

        // Edge values for Signed and Unsigned
        A = 32'hFFFF_FFFF; B = 32'h7FFF_FFFF;
        #10;
        $display("%0t\t %h \t %h \t %b  \t %b  \t %b", $time, A, B, EQ, LU, LS);
        if (EQ !== 1'b0 || LU !== 1'b0 || LS !== 1'b1) errors = errors + 1;

        #10;
        $display("---------------------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS:- All test cases passed successfully!");
        end else begin
            $display("FAILURE:- %0d test cases failed!", errors);
        end
        $display("---------------------------------------------------------------------");
        
        $finish;
	end


endmodule
