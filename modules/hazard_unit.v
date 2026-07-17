module hazard_unit (
    input  wire [4:0] id_rs1,
    input  wire [4:0] id_rs2,
    input  wire       id_uses_rs1,
    input  wire       id_uses_rs2,
    input  wire       id_is_ctrl,     // 1 if ID is BRANCH or JALR

    // --- EX stage producer ---
    input  wire [4:0] ex_rd,
    input  wire       ex_is_load,     
    input  wire       ex_write_rd,  

    // --- MEM stage producer ---
    input  wire [4:0] mem_rd,
    input  wire       mem_is_load,    // read_en_mem
    input  wire       mem_write_rd,   // write_rd_mem

    output wire       stall           
);

    // load-use (EX  → ID ) 
    wire load_use_rs1 =
        id_uses_rs1 && ex_is_load && (ex_rd == id_rs1) && (ex_rd != 5'b0);
    wire load_use_rs2 =
        id_uses_rs2 && ex_is_load && (ex_rd == id_rs2) && (ex_rd != 5'b0);
    wire load_use = load_use_rs1 || load_use_rs2;

    // control: producer still in EX or MEM
    wire ex_writes  = (ex_write_rd  || ex_is_load)  && (ex_rd  != 5'b0);
    wire mem_writes = (mem_write_rd || mem_is_load) && (mem_rd != 5'b0);

    wire ctrl_dep_ex =
        id_is_ctrl && (
            (id_uses_rs1 && ex_writes  && (ex_rd  == id_rs1)) ||
            (id_uses_rs2 && ex_writes  && (ex_rd  == id_rs2))
        );

    wire ctrl_dep_mem =
        id_is_ctrl && (
            (id_uses_rs1 && mem_writes && (mem_rd == id_rs1)) ||
            (id_uses_rs2 && mem_writes && (mem_rd == id_rs2))
        );

    wire ctrl_dep = ctrl_dep_ex || ctrl_dep_mem;

    assign stall = load_use || ctrl_dep;

endmodule
