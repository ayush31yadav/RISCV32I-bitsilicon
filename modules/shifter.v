`timescale 1ns/1ps

module lShift(
    input [31:0] X,
    input [4:0] shiftAmt,
    input SR, // shift = 0, ROTATE = 1
    output [31:0] Y
);

    wire [31:0] controlSig;
    
    decoder32 d32 (
        .X (shiftAmt),
        .Y(controlSig)
    );
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin // shift amt
            for (genvar j = 0; j < 32; j = j + 1) begin // output
                if (j - i < 0) begin
                    wire muxConnect;
                    
                    mux2_1_1 M (
                        .X0(1'b0),
                        .X1(X[j - i + 32]),
                        .select(SR),
                        .Y(muxConnect)
                    );
                    
                    tristate_buffer tsb (
                        .x(muxConnect),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end else begin
                    tristate_buffer tsb (
                        .x(X[j - i]),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end
            end
        end
    endgenerate

endmodule

module rShift(
    input [31:0] X,
    input [4:0] shiftAmt,
    input SR, // shift = 0, ROTATE = 1
    input LA, // logical = 0, ARITHMETIC = 1
    output [31:0] Y
);

    wire [31:0] controlSig;
    
    decoder32 d32 (
        .X (shiftAmt),
        .Y(controlSig)
    );
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin // shift amt
            for (genvar j = 0; j < 32; j = j + 1) begin // output
                if (j + i >= 32) begin
                    wire newBit, muxConnect;
                    
                    mux2_1_1 M_LA (
                        .X0(1'b0),
                        .X1(X[31]),
                        .select(LA),
                        .Y(newBit)
                    );
                    
                    mux2_1_1 M_SR (
                        .X0(newBit),
                        .X1(X[j + i - 32]),
                        .select(SR),
                        .Y(muxConnect)
                    );
                    
                    tristate_buffer tsb (
                        .x(muxConnect),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end else begin
                    tristate_buffer tsb (
                        .x(X[j + i]),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end
            end
        end
    endgenerate

endmodule