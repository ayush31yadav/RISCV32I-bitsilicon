`timescale 1ns/1ps

module core (
    input  wire clk, rst
);

    wire [31:0] inst_if, pc_if;
    wire [31:0] inst_id, pc_id, pc_ex;

    wire [31:0] rs1_idif, imm_idif;
    wire        sType_idif, iSpec_idif;

   wire stall;
  

    IF inst_fetch (
        .clk(clk), .rst(rst),
        .stall(stall),           
        .rs1_id(rs1_idif),
        .imm_id(imm_idif),
        .spec_type(sType_idif),
        .is_spec(iSpec_idif),
        .inst(inst_if), .pc(pc_if)
    );

  dFF_en #(.N(64)) pip_ifid (
        .D({inst_if, pc_if}),
        .clk(clk),
        .rst(rst),
        .en(~stall),             
        .Y({inst_id, pc_id})
    );


   wire [4:0] rs1_addr_id = inst_id[19:15]; 
    wire [4:0] rs2_addr_id = inst_id[24:20]; 
    wire [6:0] op_id       = inst_id[6:0];    

    wire id_uses_rs1 =
        (op_id != 7'b0110111) &&  // not LUI
        (op_id != 7'b0010111) &&  // not AUIPC
        (op_id != 7'b1101111) &&  // not JAL
        (op_id != 7'b0000000);    // not NULL/bubble

    wire id_uses_rs2 =
        (op_id == 7'b0110011) ||  // R-type
        (op_id == 7'b0100011) ||  // store
        (op_id == 7'b1100011);    // branch

    wire id_is_ctrl =
        (op_id == 7'b1100011) ||  // BRANCH
        (op_id == 7'b1100111);    // JALR

    wire [31:0] rs1_idex, rs2_idex, imm20_idex;
    wire [31:0] imm_ext_idex;
    wire        isI_idex, toggle_idex;
    wire [ 1:0] calc_type_idex;
    wire [ 2:0] func_sel_idex;

    wire        write_en_mem_idex, read_en_mem_idex;
    wire [ 1:0] write_size_mem_idex, read_size_mem_idex;
    wire        read_us_mem_idex;

    wire        write_rd_idex;
    wire [ 4:0] rd_idex;

    wire [31:0] rs1_ex, rs2_ex, imm20_ex;
    wire [31:0] imm_ext_ex;
    wire        isI_ex, toggle_ex;
    wire [ 1:0] calc_type_ex;
    wire [ 2:0] func_sel_ex;

    wire        write_en_mem_ex, read_en_mem_ex;
    wire [ 1:0] write_size_mem_ex, read_size_mem_ex;
    wire        read_us_mem_ex;
    
    wire        write_rd_ex;
    wire [ 4:0] rd_ex;


 wire [4:0] rs1_addr_ex;   // source reg no in EX (for forwarding)
    wire [4:0] rs2_addr_ex;
    wire [31:0] new_val_rd;
    wire        write_en_rd;
    wire [ 4:0] write_to_rd;

    ID inst_decode (
        .clk(clk),.rst(rst),
        .inst(inst_id),
        .data_write(new_val_rd),
        .write_en(write_en_rd),
        .write_to(write_to_rd),

        .rs1_if(rs1_idif),
        .imm_if(imm_idif),
        .pc_sel_specType(sType_idif), .pc_sel_isSpec(iSpec_idif),
        // EXEC
        .rs1_ex(rs1_idex), .rs2_ex(rs2_idex), .imm20_ex(imm20_idex),
        .imm_ext_ex(imm_ext_idex),
        .isI_ex(isI_idex), .toggle_ex(toggle_idex),
        .calc_type_ex(calc_type_idex),
        .func_sel_ex(func_sel_idex),
        // MEM
        .write_en_mem(write_en_mem_idex), .read_en_mem(read_en_mem_idex),
        .write_size_mem(write_size_mem_idex), .read_size_mem(read_size_mem_idex),
        .read_us_mem(read_us_mem_idex),
        // GEN
        .write_rd(write_rd_idex),
        .rd(rd_idex)
    );

   
    wire        isI_b          = stall ? 1'b0 : isI_idex;
    wire        toggle_b       = stall ? 1'b0 : toggle_idex;
    wire [1:0]  calc_type_b    = stall ? 2'b00 : calc_type_idex;
    wire [2:0]  func_sel_b     = stall ? 3'b000 : func_sel_idex;
    wire        write_en_mem_b = stall ? 1'b0 : write_en_mem_idex;
    wire        read_en_mem_b  = stall ? 1'b0 : read_en_mem_idex;
    wire [1:0]  write_size_b   = stall ? 2'b00 : write_size_mem_idex;
    wire [1:0]  read_size_b    = stall ? 2'b00 : read_size_mem_idex;
    wire        read_us_b      = stall ? 1'b0 : read_us_mem_idex;
    wire        write_rd_b     = stall ? 1'b0 : write_rd_idex;
    wire [4:0]  rd_b           = stall ? 5'b0 : rd_idex;
    wire [4:0]  rs1_addr_b     = stall ? 5'b0 : rs1_addr_id;
    wire [4:0]  rs2_addr_b     = stall ? 5'b0 : rs2_addr_id;


      wire [31:0] rd_val_m;
    wire        write_en_mem, read_en_mem;
    wire [ 1:0] write_size_mem, read_size_mem;
    wire        read_us_mem, write_rd_mem;
    wire [ 4:0] rd_mem;
    wire [31:0] rs2_mem;

    dFF #(.N(190)) pip_idex (
        .D({
            pc_id,          
            rs1_idex,       
            rs2_idex,       
            imm20_idex,     
            imm_ext_idex,   
            isI_b,         
            toggle_b,      
            calc_type_b,   
            func_sel_b,    
            write_en_mem_b,
            read_en_mem_b, 
            write_size_b,  
            read_size_b,   
            read_us_b,     
            write_rd_b,    
            rd_b,           
            rs1_addr_b,     
            rs2_addr_b      
        }),
        .clk(clk),
        .rst(rst),
        .Y({
            pc_ex,
            rs1_ex,
            rs2_ex,
            imm20_ex,
            imm_ext_ex,
            isI_ex,
            toggle_ex,
            calc_type_ex,
            func_sel_ex,
            write_en_mem_ex,
            read_en_mem_ex,
            write_size_mem_ex,
            read_size_mem_ex,
            read_us_mem_ex,
            write_rd_ex,
            rd_ex,
            rs1_addr_ex,    
            rs2_addr_ex     
        })
    );
    wire [31:0] rd_val;

    hazard_unit u_hazard (
        .id_rs1       (rs1_addr_id),
        .id_rs2       (rs2_addr_id),
        .id_uses_rs1  (id_uses_rs1),
        .id_uses_rs2  (id_uses_rs2),
        .id_is_ctrl   (id_is_ctrl),
        .ex_rd        (rd_ex),
        .ex_is_load   (read_en_mem_ex),
        .ex_write_rd  (write_rd_ex),
        .mem_rd       (rd_mem),
        .mem_is_load  (read_en_mem),
        .mem_write_rd (write_rd_mem),
        .stall        (stall)
    );

    wire [1:0] forwardA;  
    wire [1:0] forwardB;  
    wire mem_regwrite = write_rd_mem;

   
    wire wb_regwrite = write_en_rd;

    forward_unit u_forward (
        .ex_rs1       (rs1_addr_ex),
        .ex_rs2       (rs2_addr_ex),
        .mem_rd       (rd_mem),
        .mem_regwrite (mem_regwrite && (rd_mem != 5'b0)),
        .wb_rd        (write_to_rd),   // same as rd_wb
        .wb_regwrite  (wb_regwrite && (write_to_rd != 5'b0)),
        .forwardA     (forwardA),
        .forwardB     (forwardB)
    );

    wire [31:0] rs1_fwd =
        (forwardA == 2'b10) ? rd_val_m   :
        (forwardA == 2'b01) ? new_val_rd :
                              rs1_ex;

    wire [31:0] rs2_fwd =
        (forwardB == 2'b10) ? rd_val_m   :
        (forwardB == 2'b01) ? new_val_rd :
                              rs2_ex;
    EX execute (
        .rs1(rs1_fwd), .rs2(rs2_fwd), .PC(pc_ex),
        .imm_ext(imm_ext_ex), .imm20(imm20_ex),
        .is_I(isI_ex), .f_toggle(toggle_ex),
        .calc_type(calc_type_ex),
        .func_sel(func_sel_ex),
        .rd(rd_val)
    );


    dFF #(.N(77)) pip_exmem (
        .D({rd_val, write_en_mem_ex, read_en_mem_ex, write_size_mem_ex, read_size_mem_ex,
        read_us_mem_ex, write_rd_ex, rd_ex, rs2_fwd}),
        .clk(clk), .rst(rst),
        .Y({rd_val_m, write_en_mem, read_en_mem, write_size_mem, read_size_mem,
        read_us_mem, write_rd_mem, rd_mem, rs2_mem})
    );

    wire [31:0] mem_read_val;

    memory mem (
        .clk(clk), .rst(rst),
        .wr_en(write_en_mem),
        .rd_en(read_en_mem),
        .write_size(write_size_mem),
        .read_size(read_size_mem),
        .read_us(read_us_mem),

        .wr_addr(rd_val_m),
        .rd_addr(rd_val_m),

        .data_write(rs2_mem),
        .data_read(mem_read_val)
    );

    wire        read_en_mem_wb, write_rd_wb;
    wire [31:0] rd_val_wb, mem_read_wb;
    wire [ 4:0] rd_wb;

    dFF #(.N(71)) pip_memwb (
        .D({read_en_mem, rd_val_m, write_rd_mem, rd_mem, mem_read_val}),
        .clk(clk), .rst(rst),
        .Y({read_en_mem_wb, rd_val_wb, write_rd_wb, rd_wb, mem_read_wb})
    );

    mux2 #(.N(32)) rd_select (
        .d0(rd_val_wb),
        .d1(mem_read_wb),
        .sel(read_en_mem_wb),
        .Y(new_val_rd)
    );

    assign write_en_rd = read_en_mem_wb | write_rd_wb;
    assign write_to_rd = rd_wb;
 always @(posedge clk) begin
        if (!rst) begin
            if (stall)
                $display("%0t STALL load->x%0d ; ID needs rs1=x%0d rs2=x%0d",
                         $time, rd_ex, rs1_addr_id, rs2_addr_id);
            if (forwardA != 2'b00)
                $display("%0t FWD_A=%b rs1=x%0d val=%h",
                         $time, forwardA, rs1_addr_ex, rs1_fwd);
            if (forwardB != 2'b00)
                $display("%0t FWD_B=%b rs2=x%0d val=%h",
                         $time, forwardB, rs2_addr_ex, rs2_fwd);
        end
    end
endmodule