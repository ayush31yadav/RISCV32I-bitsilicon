`timescale 1ns/1ps

module mux2 #(
    parameter N = 32
) (
    input  wire [N-1:0] d0, d1,
    input  wire         sel,
    output reg  [N-1:0] Y
);

    always @(*) begin
        case (sel)
            1'b0 : Y <= d0;
            1'b1 : Y <= d1;
        endcase
    end

endmodule

module mux4 #(
    parameter N = 32
) (
    input  wire [N-1:0] d0, d1, d2, d3,
    input  wire [1:0]   sel,
    output reg  [N-1:0] Y
);

    always @(*) begin
        case (sel)
            2'b00 : Y <= d0;
            2'b01 : Y <= d1;
            2'b10 : Y <= d2;
            2'b11 : Y <= d3;
        endcase
    end

endmodule

module mux8 #(
    parameter N = 32
) (
    input  wire [N-1:0] d0, d1, d2, d3, d4, d5, d6, d7,
    input  wire [2:0]   sel,
    output reg  [N-1:0] Y
);

    always @(*) begin
        case (sel)
            3'b000 : Y <= d0;
            3'b001 : Y <= d1;
            3'b010 : Y <= d2;
            3'b011 : Y <= d3;
            3'b100 : Y <= d4;
            3'b101 : Y <= d5;
            3'b110 : Y <= d6;
            3'b111 : Y <= d7;
        endcase
    end

endmodule