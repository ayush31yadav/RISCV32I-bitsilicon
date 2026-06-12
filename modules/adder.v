module adder(
	input wire [31:0] A,						// Operand A
	input wire [31:0] B,						// Operand B
	input wire add_sub, 						// 0 = Add, 1 = Subtract
	output wire [31:0] sum,						// 32-bit Result
	output wire carry_out,						// adding overflow bit
	output wire zero							// Zero Flag
);

	wire [31:0] b_eqv;							// creating an equivalent B for 2's complement
	assign b_eqv = add_sub ? ~B : B;			// 0 = Same, 1 = 1's complement
	
	wire [32:0] full_sum;						// for adjusting carry out
	assign full_sum = A + b_eqv + add_sub;		// performing addition
	assign sum = full_sum[31:0];				// ignoring carry bit for final output
	assign carry_out = full_sum[32];			// assigning overflow bit	
	assign zero = (sum == 32'b0);				// assigning zero bit

endmodule