`timescale 1ns/1ps

module tristate_buffer (
    input x,     // Data input
    input c,     // Control (enable)
    output y     // Output
);

assign y = c ? x : 1'bz;

endmodule

module decoder32(
    input [4:0] X,
    output [31:0] Y
);
    
    wire [4:0] n;
    
    not (n[0], X[0]);
    not (n[1], X[1]);
    not (n[2], X[2]);
    not (n[3], X[3]);
    not (n[4], X[4]);
    
    and (Y[00], n[4], n[3], n[2], n[1], n[0]);
    and (Y[01], n[4], n[3], n[2], n[1], X[0]);
    and (Y[02], n[4], n[3], n[2], X[1], n[0]);
    and (Y[03], n[4], n[3], n[2], X[1], X[0]);
    and (Y[04], n[4], n[3], X[2], n[1], n[0]);
    and (Y[05], n[4], n[3], X[2], n[1], X[0]);
    and (Y[06], n[4], n[3], X[2], X[1], n[0]);
    and (Y[07], n[4], n[3], X[2], X[1], X[0]);
    and (Y[08], n[4], X[3], n[2], n[1], n[0]);
    and (Y[09], n[4], X[3], n[2], n[1], X[0]);
    and (Y[10], n[4], X[3], n[2], X[1], n[0]);
    and (Y[11], n[4], X[3], n[2], X[1], X[0]);
    and (Y[12], n[4], X[3], X[2], n[1], n[0]);
    and (Y[13], n[4], X[3], X[2], n[1], X[0]);
    and (Y[14], n[4], X[3], X[2], X[1], n[0]);
    and (Y[15], n[4], X[3], X[2], X[1], X[0]);
    and (Y[16], X[4], n[3], n[2], n[1], n[0]);
    and (Y[17], X[4], n[3], n[2], n[1], X[0]);
    and (Y[18], X[4], n[3], n[2], X[1], n[0]);
    and (Y[19], X[4], n[3], n[2], X[1], X[0]);
    and (Y[20], X[4], n[3], X[2], n[1], n[0]);
    and (Y[21], X[4], n[3], X[2], n[1], X[0]);
    and (Y[22], X[4], n[3], X[2], X[1], n[0]);
    and (Y[23], X[4], n[3], X[2], X[1], X[0]);
    and (Y[24], X[4], X[3], n[2], n[1], n[0]);
    and (Y[25], X[4], X[3], n[2], n[1], X[0]);
    and (Y[26], X[4], X[3], n[2], X[1], n[0]);
    and (Y[27], X[4], X[3], n[2], X[1], X[0]);
    and (Y[28], X[4], X[3], X[2], n[1], n[0]);
    and (Y[29], X[4], X[3], X[2], n[1], X[0]);
    and (Y[30], X[4], X[3], X[2], X[1], n[0]);
    and (Y[31], X[4], X[3], X[2], X[1], X[0]);
    
endmodule

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
                    
                    mux2 #(.N(1)) M (
                        .d0(1'b0), 
                        .d1(X[j - i + 32]),
                        .sel(SR),
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

                    mux2 #(.N(1)) M_LA (
                        .d0(1'b0), 
                        .d1(X[31]),
                        .sel(LA),
                        .Y(newBit)
                    );

                    mux2 #(.N(1)) M_SR (
                        .d0(newBit), 
                        .d1(X[j + i - 32]),
                        .sel(SR),
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