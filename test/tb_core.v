`timescale 1ns/1ps

module tb_core;
    reg clk, rst;

    core uut (
        .clk(clk), .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #12 rst = 0;
        #800 $finish;   // Run longer to see jumps + hazards
    end

    // ======================  PIPELINE TRACE ======================
    always @(posedge clk) begin
        if (!rst) begin
            $display("=== Time=%0t | Cycle=%0d ===", $time, $time/10);
            
            // IF Stage
            $display("IF : PC=0x%08h  Inst=0x%08h", uut.pc_if, uut.inst_if);
            
            // ID Stage
            $display("ID : PC=0x%08h  Inst=0x%08h  rs1=%0d rs2=%0d rd=%0d", 
                     uut.pc_id, uut.inst_id, 
                     uut.inst_id[19:15], uut.inst_id[24:20], uut.inst_id[11:7]);
            
            // EX Stage
            $display("EX : rs1=0x%08h rs2=0x%08h  ALU_Result=0x%08h", 
                     uut.rs1_ex, uut.rs2_ex, uut.rd_val);   // rd_val is from EX
            
            // MEM Stage
            $display("MEM: Addr=0x%08h  Write=%b Read=%b  DataW=0x%08h DataR=0x%08h", 
                     uut.rd_val_m, uut.write_en_mem, uut.read_en_mem, 
                     uut.rs2_mem, uut.mem_read_val);
            
            // WB Stage
            $display("WB : WriteTo=x%02d  Value=0x%08h", uut.write_to_rd, uut.new_val_rd);
            
            $display("-----------------------------------------------------");
        end
    end

   

endmodule