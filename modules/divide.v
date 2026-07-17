`timescale 1ns/1ps

module divide (
    input clk,
    input reset,
    input start,
    input is_signed,
    input [31:0] dividend,
    input [31:0] divisor,
    output reg [31:0] quotient,
    output reg [31:0] remainder,
    output reg done
);
    parameter IDLE = 2'd0,
              EDGE = 2'd1,
              CALC = 2'd2,
              DONE = 2'd3;

    reg [1:0]  state;
    reg [5:0]  count;
    reg [31:0] dvnd_abs;
    reg [31:0] dvsr_abs;
    reg neg_quot;
    reg neg_rem;
    reg [63:0] partial;

    wire [63:0] shifted = partial << 1;
    wire [32:0] sub_result = {1'b0, shifted[63:32]} - {1'b0, dvsr_abs};
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            done      <= 1'b0;
            quotient  <= 32'd0;
            remainder <= 32'd0;
            count     <= 6'd0;
            partial   <= 64'd0;
            dvnd_abs  <= 32'd0;
            dvsr_abs  <= 32'd0;
            neg_quot  <= 1'b0;
            neg_rem   <= 1'b0;
        end
        else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (start) begin
                        if (is_signed) begin
                            if (dividend[31] == 1'b1)
                                dvnd_abs <= (~dividend + 1'b1);
                            else
                                dvnd_abs <= dividend;
                            if (divisor[31] == 1'b1)
                                dvsr_abs <= (~divisor  + 1'b1);
                            else
                                dvsr_abs <= divisor;
                            neg_quot <= dividend[31] ^ divisor[31];
                            neg_rem  <= dividend[31];
                        end
                        else begin
                            dvnd_abs <= dividend;
                            dvsr_abs <= divisor;
                            neg_quot <= 1'b0;
                            neg_rem  <= 1'b0;
                        end
                        state <= EDGE;
                    end
                end
                
                EDGE: begin
                    if (dvsr_abs == 32'd0) begin
                        quotient  <= 32'hFFFF_FFFF;
                        remainder <= dividend;
                        done      <= 1'b1;
                        state     <= IDLE;
                    end
                    else if (is_signed && dividend == 32'h8000_0000 && divisor  == 32'hFFFF_FFFF) begin
                        quotient  <= 32'h8000_0000;
                        remainder <= 32'd0;
                        done      <= 1'b1;
                        state     <= IDLE;
                    end
                    else begin
                        partial <= {32'd0, dvnd_abs};
                        count   <= 6'd0;
                        state   <= CALC;
                    end
                end

                CALC: begin
                    if (!sub_result[32]) begin
                        partial <= {sub_result[31:0], shifted[31:0] | 32'd1};
                    end
                    else begin
                        partial <= {shifted[63:32], shifted[31:0]};
                    end

                    if (count == 6'd31) begin
                        state <= DONE;
                    end
                    else begin
                        count <= count + 1'b1;
                    end
                end
                
                DONE: begin
                    quotient  <= neg_quot ? (~partial[31:0]  + 1'b1) : partial[31:0];
                    remainder <= neg_rem  ? (~partial[63:32] + 1'b1) : partial[63:32];
                    done      <= 1'b1;
                    state     <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
