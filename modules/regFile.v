`timescale 1ns/1ps

module regFile (
    input  wire [31:0] data_write,
    input  wire [ 4:0] reg_read_1, reg_read_2, reg_write,
    input  wire        clk,
    input  wire        write_en,
    output wire [31:0] data_read1, data_read2 
);

    wire [31:0] w_en;
    wire [31:0] r_out [31:1];

    generate
        for (genvar i = 1; i < 32; i = i + 1) begin
            dReg #(.N(32)) D (
                .D(data_write),
                .clk(clk), .write_en(w_en[i]),
                .Y(r_out[i])
            );
        end
    endgenerate

    assign data_read1 = (|reg_read_1) ? r_out[32'h0000_0001 << reg_read_1] : 32'b0;
    assign data_read2 = (|reg_read_2) ? r_out[32'h0000_0001 << reg_read_2] : 32'b0;

    assign w_en = 32'h0000_0001 << (write_en ? reg_write : 32'b0);

endmodule