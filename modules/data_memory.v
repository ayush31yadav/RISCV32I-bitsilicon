`timescale 1ns / 1ps

// Strict Little Endian Memory Module
module memory(
    input wire        clk, rst,
    input wire        wr_en,                    // 1: write , 0: idle
    input wire        rd_en,                    // 1: read , 0: idle
    input wire [ 1:0] write_size,               // 0: BYTE; 1: HALF WORD; 2,3: WORD
    input wire [ 1:0] read_size,                // 0: BYTE; 1: HALF WORD; 2,3: WORD
    input wire        read_us,                  // Unsigned = 1; Signed = 0
    input wire [31:0] data_write,               // Data to be written
    input wire [31:0] wr_addr,                  // Write address
    input wire [31:0] rd_addr,                  // Read address
    output reg [31:0] data_read                 // Data read at read address
);
    
    reg [7:0] mem [255:0];
    
    integer i;
    always @(negedge clk or posedge rst)
    begin 
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)mem[i] <= 8'b0;
            data_read <= 32'b0;
        end else begin
            
            if (wr_en && !rd_en) begin

                case (write_size)
                    2'b00 : mem[wr_addr[7:0]] <= data_write[7:0];
                    2'b01 : begin
                        mem[wr_addr[7:0]]     <= data_write[7:0]; 
                        mem[wr_addr[7:0] + 1] <= data_write[15:8];
                    end
                    default : begin
                        mem[wr_addr[7:0]]     <= data_write[7:0];
                        mem[wr_addr[7:0] + 1] <= data_write[15:8];
                        mem[wr_addr[7:0] + 2] <= data_write[23:16];
                        mem[wr_addr[7:0] + 3] <= data_write[31:24];
                    end
                endcase

            end else if (rd_en && !wr_en) begin

                casex ({read_us, read_size})
                    3'b000  : data_read <= {{24{mem[rd_addr[7:0]][7]}}, mem[rd_addr[7:0]]};
                    3'b001  : data_read <= {{16{mem[rd_addr[7:0] + 1][7]}}, mem[rd_addr[7:0] + 1], mem[rd_addr[7:0]]};
                    3'b01x  : data_read <= {mem[rd_addr[7:0] + 3], mem[rd_addr[7:0] + 2], mem[rd_addr[7:0] + 1], mem[rd_addr[7:0]]};
                    3'b100  : data_read <= {24'b0, mem[rd_addr[7:0]]};
                    3'b101  : data_read <= {16'b0, mem[rd_addr[7:0] + 1], mem[rd_addr[7:0]]};
                    default : data_read <= 32'b0;
                endcase

            end else begin
                data_read <= 32'b0;
            end
        end     
    end
    
endmodule