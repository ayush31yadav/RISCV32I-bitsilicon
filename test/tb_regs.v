`timescale 1ns/1ps

module tb_regs();

    // Sample Width
    parameter WIDTH = 8;

    // Inputs as registers
    reg	clk;
    reg	rst;
    reg	write_en;
    reg  [WIDTH-1:0] D;
    
    // Output as wires
    wire [WIDTH-1:0] Y_dff;
    wire [WIDTH-1:0] Y_dreg;

    // Error tracker
    integer errors = 0;

    // Dut for FF
    dFF #(
        .N(WIDTH)
    ) dut_dff (
        .D(D),
        .clk(clk),
        .rst(rst),
        .Y(Y_dff)
    );

    // Dut for Reg
    dReg #(
        .N(WIDTH)
    ) dut_dreg (
        .D(D),
        .clk(clk),
        .write_en(write_en),
        .Y(Y_dreg)
    );

    // Clock Gen
    always begin
        #10 clk = ~clk;
    end

    // Stimulus
    initial begin
        clk      = 1'b0;
        rst      = 1'b0;
        write_en = 1'b0;
        D        = {WIDTH{1'b0}};

        $display("Time\t rst \t write_en \t D   \t Y_dff \t Y_dreg");
        $display("----------------------------------------------------------------------------------------");

        // Reset
        #5;
        rst = 1'b1; 
        #5;
        $display("%0t\t  %b  \t    %b    \t %h  \t  %h   \t   %h   (Expected Y_dff=00)", $time, rst, write_en, D, Y_dff, Y_dreg);
        if (Y_dff !== {WIDTH{1'b0}}) errors = errors + 1;

        @(negedge clk);
        rst = 1'b0;
        #1;

        // Write without en
        @(negedge clk);
        D        = 8'hA5;
        write_en = 1'b0;
        
        @(posedge clk);
        #1;
        $display("%0t\t  %b  \t    %b    \t %h  \t  %h   \t   %h   (Expected Y_dff=A5, Y_dreg=xx/00)", $time, rst, write_en, D, Y_dff, Y_dreg);
        if (Y_dff !== 8'hA5) begin
            $display("ERROR: dFF failed to update.");
            errors = errors + 1;
        end
        if (Y_dreg === 8'hA5) begin
            $display("ERROR: dReg updated despite write_en being 0.");
            errors = errors + 1;
        end

        // Write with en
        @(negedge clk);
        D        = 8'h5A;
        write_en = 1'b1;

        @(posedge clk);
        #1;
        $display("%0t\t  %b  \t    %b    \t %h  \t  %h   \t   %h   (Expected Y_dff=5A, Y_dreg=5A)", $time, rst, write_en, D, Y_dff, Y_dreg);
        if (Y_dff !== 8'h5A || Y_dreg !== 8'h5A) begin
            $display("ERROR: Register failed to capture data on write enable.");
            errors = errors + 1;
        end

        // Check if value holds
        @(negedge clk);
        D        = 8'hFF;
        write_en = 1'b0;

        @(posedge clk);
        #1;
        $display("%0t\t  %b  \t    %b    \t %h  \t  %h   \t   %h   (Expected Y_dff=FF, Y_dreg=5A)", $time, rst, write_en, D, Y_dff, Y_dreg);
        if (Y_dff !== 8'hFF) begin
            $display("ERROR: dFF failed to update value.");
            errors = errors + 1;
        end
        if (Y_dreg !== 8'h5A) begin
            $display("ERROR: dReg failed to hold its stable value.");
            errors = errors + 1;
        end
        #20;
        $display("----------------------------------------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS:- All test cases passed successfully!");
        end else begin
            $display("FAILURE:- %0d verification check errors encountered!", errors);
        end
        $display("----------------------------------------------------------------------------------------");
        
        $finish;
    end

endmodule