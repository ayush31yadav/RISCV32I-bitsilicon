`timescale 1ns/1ps

module forward_unit (
    // EX instruction source register
    input  wire [4:0] ex_rs1,
    input  wire [4:0] ex_rs2,

    input  wire [4:0] mem_rd,         
    input  wire       mem_regwrite,   

    input  wire [4:0] wb_rd,         
    input  wire       wb_regwrite,    

    output wire [1:0] forwardA,       // for rs1
    output wire [1:0] forwardB        // for rs2
);


    assign forwardA =
        (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs1)) ? 2'b10 :
        (wb_regwrite  && (wb_rd  != 5'b0) && (wb_rd  == ex_rs1)) ? 2'b01 :
                                                                    2'b00;

    assign forwardB =
        (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs2)) ? 2'b10 :
        (wb_regwrite  && (wb_rd  != 5'b0) && (wb_rd  == ex_rs2)) ? 2'b01 :
                                                                    2'b00;

endmodule