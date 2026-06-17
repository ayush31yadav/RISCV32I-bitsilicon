module Comparator(
    input  wire [31:0] A, B,
    output wire LS,          //high if lesser signed
    output wire LU,          //high if lesser unsigned
    output wire EQ           //high if equal
);
    
    
    assign EQ = (A==B);
    assign LU = (A<B);
    assign LS = ($signed(A) < $signed(B));
    
endmodule