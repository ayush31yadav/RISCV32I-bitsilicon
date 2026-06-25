`timescale 1ns / 1ps

module memory(
	input wire clk,								// Clock
	input wire rst,								// Reset
    input wire wr_en,							// 1: write , 0: idle
	input wire rd_en,							// 1: read , 0: idle
	input wire [31:0] data_write,				// Data to be written
	input wire [31:0] wr_addr,					// Write address
	input wire [31:0] rd_addr,					// Read address
	output reg [31:0] data_read				    // Data read at read address
    );
	
	reg [31:0] mem [31:0];
	
	integer i;
	always@(posedge clk or posedge rst)
	begin 
		if (rst) 
			begin
				for (i=0; i<32; i=i+1) mem[i] <= 32'b0;
				data_read <= 32'b0;
			end
		else
			begin
				if (wr_en && !rd_en)
					begin
						mem[wr_addr[4:0]] <= data_write;
						data_read <= 32'b0;
					end
				else if(rd_en && !wr_en)
					begin
						data_read <= mem[rd_addr[4:0]];
					end
				else
					begin
						data_read <= 32'b0;
					end
			end		
	end
	
endmodule
