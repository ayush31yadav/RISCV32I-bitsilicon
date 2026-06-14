module Comparator(
    input [31:0] A,
    input [31:0] B,

    output LS,          //high if lesser signed
    output LU,          //high if lesser unsigned
    output E            //high if equal
    );
    
    
    assign E = (A==B);
    assign LU = (A<B);
    assign LS = ( $signed(A) < $signed(B));
    
    
endmodule
