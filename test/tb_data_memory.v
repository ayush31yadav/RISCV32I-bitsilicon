`timescale 1ns / 1ps

module tb_memory;

    // Declare Inputs as registers (reg) and Outputs as wires
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [31:0] data_write;
    reg [31:0] wr_addr;
    reg [31:0] rd_addr;
    wire [31:0] data_read;

    // Instantiate the Unit Under Test (UUT)
    memory uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_write(data_write),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .data_read(data_read)
    );

    // Generate a clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // Stimulus
    initial begin
        // Initialise all inputs
        rst = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        data_write = 32'b0;
        wr_addr = 32'b0;
        rd_addr = 32'b0;
        
        $display("Time\t\tAddr\tData Read");
        $display("------------------------------");

        // Applying Reset 
        rst = 1'b1;
        #15;
        rst = 1'b0;
        #5;
        
        // Write data to Address 5
        @(posedge clk);
        wr_en = 1'b1;
        rd_en = 1'b0;
        wr_addr = 32'd5;
        data_write = 32'h12F73A92;
        
        // Write data to Address 28
        @(posedge clk);
        wr_addr = 32'd28;
        data_write = 32'h97462AB1;
        
        // Return to Idle before verifying
        @(posedge clk);
        wr_en = 1'b0;
        data_write = 32'b0;
        #10;

        // Read and Verify Address 5
        @(posedge clk);
        rd_en = 1'b1;
        rd_addr = 32'd5;
        
        @(posedge clk);
        #1; 
        $display("%0t ns\t5\t\t%h", $time, data_read);
        if (data_read !== 32'h12F73A92) begin
            $display("[ERROR] Address 5 read failed! Expected 0x12F73A92, Got: %h", data_read);
            $stop;
        end

        // Read and Verify Address 28
        @(posedge clk);
        rd_addr = 32'd28;
        
        @(posedge clk);
        #1;
        $display("%0t ns\t28\t\t%h", $time, data_read);
        if (data_read !== 32'h97462AB1) begin
            $display("[ERROR] Address 28 read failed! Expected 0x97462AB1, Got: %h", data_read);
            $stop;
        end

        // Verify if output clears when Read is disabled
        rd_en = 1'b0;
        rd_addr = 32'b0;
		
        @(posedge clk);
        #1;
        if (data_read !== 32'b0) begin
            $display("[ERROR] Output failed to clear during idle state! Got: %h", data_read);
            $stop;
        end

        $display("------------------------------");
        $display("Success: All data memory read/write operations verified perfectly!");
        $finish;
    end

endmodule