module Comparator(
    input [31:0] A,
    input [31:0] B,
    output GU,          //greater unsigned
    output GS,          //greater signed
    output LS,          //lesser signed
    output LU,          //lesser unsigned
    output E            //equal
    );
    
    
    assign GU = (A>B);
    assign E = (A==B);
    assign LU = (A<B);
    
    assign LS = ( $signed(A) < $signed(B));
    assign GS = ( $signed(A) > $signed(B));
    
    
endmodule
