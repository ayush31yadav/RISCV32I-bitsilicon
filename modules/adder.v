module adder (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire        add_sub,   // 0 = Add, 1 = Subtract
    output wire [31:0] sum,
    output wire        carry_out // to prevent linting violations
);

    // Handle 2's complement subtraction conversion
    wire [31:0] b_eqv;
    assign b_eqv = add_sub ? ~B : B;

    // Declare Generate (G) and Propagate (P) arrays for all 32 bits
    wire [31:0] G;
    wire [31:0] P;
    assign G = A & b_eqv;
    assign P = A ^ b_eqv;

    // Declare Group Generate (GG) and Group Propagate (GP) for the eight 4-bit blocks
    wire [7:0] GG;
    wire [7:0] GP;

    // Block 0 (Bits 3:0)
    assign GG[0] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
    assign GP[0] = P[3] & P[2] & P[1] & P[0];

    // Block 1 (Bits 7:4)
    assign GG[1] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]);
    assign GP[1] = P[7] & P[6] & P[5] & P[4];

    // Block 2 (Bits 11:8)
    assign GG[2] = G[11] | (P[11] & G[10]) | (P[11] & P[10] & G[9]) | (P[11] & P[10] & P[9] & G[8]);
    assign GP[2] = P[11] & P[10] & P[9] & P[8];

    // Block 3 (Bits 15:12)
    assign GG[3] = G[15] | (P[15] & G[14]) | (P[15] & P[14] & G[13]) | (P[15] & P[14] & P[13] & G[12]);
    assign GP[3] = P[15] & P[14] & P[13] & P[12];

    // Block 4 (Bits 19:16)
    assign GG[4] = G[19] | (P[19] & G[18]) | (P[19] & P[18] & G[17]) | (P[19] & P[18] & P[17] & G[16]);
    assign GP[4] = P[19] & P[18] & P[17] & P[16];

    // Block 5 (Bits 23:20)
    assign GG[5] = G[23] | (P[23] & G[22]) | (P[23] & P[22] & G[21]) | (P[23] & P[22] & P[21] & G[20]);
    assign GP[5] = P[23] & P[22] & P[21] & P[20];

    // Block 6 (Bits 27:24)
    assign GG[6] = G[27] | (P[27] & G[26]) | (P[27] & P[26] & G[25]) | (P[27] & P[26] & P[25] & G[24]);
    assign GP[6] = P[27] & P[26] & P[25] & P[24];

    // Block 7 (Bits 31:28)
    assign GG[7] = G[31] | (P[31] & G[30]) | (P[31] & P[30] & G[29]) | (P[31] & P[30] & P[29] & G[28]);
    assign GP[7] = P[31] & P[30] & P[29] & P[28];

    // This calculates the carry-in for each of the 4-bit blocks in parallel
    wire [8:0] C_block;
    assign C_block[0] = add_sub; 
    assign C_block[1] = GG[0] | (GP[0] & C_block[0]);
    assign C_block[2] = GG[1] | (GP[1] & GG[0]) | (GP[1] & GP[0] & C_block[0]);
    assign C_block[3] = GG[2] | (GP[2] & GG[1]) | (GP[2] & GP[1] & GG[0]) | (GP[2] & GP[1] & GP[0] & C_block[0]);
    assign C_block[4] = GG[3] | (GP[3] & GG[2]) | (GP[3] & GP[2] & GG[1]) | (GP[3] & GP[2] & GP[1] & GG[0]) | (GP[3] & GP[2] & GP[1] & GP[0] & C_block[0]);
    assign C_block[5] = GG[4] | (GP[4] & C_block[4]);
    assign C_block[6] = GG[5] | (GP[5] & GG[4]) | (GP[5] & GP[4] & C_block[4]);
    assign C_block[7] = GG[6] | (GP[6] & GG[5]) | (GP[6] & GP[5] & GG[4]) | (GP[6] & GP[5] & GP[4] & C_block[4]);
    assign C_block[8] = GG[7] | (GP[7] & GG[6]) | (GP[7] & GP[6] & GG[5]) | (GP[7] & GP[6] & GP[5] & GG[4]) | (GP[7] & GP[6] & GP[5] & GP[4] & C_block[4]);

    // Calculating individual carries within each block
    wire [31:0] C;
    
    // Carries for Block 0
    assign C[0]  = C_block[0];
    assign C[1]  = G[0]  | (P[0]  & C[0]);
    assign C[2]  = G[1]  | (P[1]  & G[0])  | (P[1]  & P[0]  & C[0]);
    assign C[3]  = G[2]  | (P[2]  & G[1])  | (P[2]  & P[1]  & G[0])  | (P[2]  & P[1]  & P[0]  & C[0]);
    
    // Carries for Block 1
    assign C[4]  = C_block[1];
    assign C[5]  = G[4]  | (P[4]  & C[4]);
    assign C[6]  = G[5]  | (P[5]  & G[4])  | (P[5]  & P[4]  & C[4]);
    assign C[7]  = G[6]  | (P[6]  & G[5])  | (P[6]  & P[5]  & G[4])  | (P[6]  & P[5]  & P[4]  & C[4]);
    
    // Carries for Block 2
    assign C[8]  = C_block[2];
    assign C[9]  = G[8]  | (P[8]  & C[8]);
    assign C[10] = G[9]  | (P[9]  & G[8])  | (P[9]  & P[8]  & C[8]);
    assign C[11] = G[10] | (P[10] & G[9])  | (P[10] & P[9] & G[8])  | (P[10] & P[9] & P[8] & C[8]);
    
    // Carries for Block 3
    assign C[12] = C_block[3];
    assign C[13] = G[12] | (P[12] & C[12]);
    assign C[14] = G[13] | (P[13] & G[12]) | (P[13] & P[12] & C[12]);
    assign C[15] = G[14] | (P[14] & G[13]) | (P[14] & P[13] & G[12]) | (P[14] & P[13] & P[12] & C[12]);
    
    // Carries for Block 4
    assign C[16] = C_block[4];
    assign C[17] = G[16] | (P[16] & C[16]);
    assign C[18] = G[17] | (P[17] & G[16]) | (P[17] & P[16] & C[16]);
    assign C[19] = G[18] | (P[18] & G[17]) | (P[18] & P[17] & G[16]) | (P[18] & P[17] & P[16] & C[16]);
    
    // Carries for Block 5
    assign C[20] = C_block[5];
    assign C[21] = G[20] | (P[20] & C[20]);
    assign C[22] = G[21] | (P[21] & G[20]) | (P[21] & P[20] & C[20]);
    assign C[23] = G[22] | (P[22] & G[21]) | (P[22] & P[21] & G[20]) | (P[22] & P[21] & P[20] & C[20]);
    
    // Carries for Block 6
    assign C[24] = C_block[6];
    assign C[25] = G[24] | (P[24] & C[24]);
    assign C[26] = G[25] | (P[25] & G[24]) | (P[25] & P[24] & C[24]);
    assign C[27] = G[26] | (P[26] & G[25]) | (P[26] & P[25] & G[24]) | (P[26] & P[25] & P[24] & C[24]);
    
    // Carries for Block 7
    assign C[28] = C_block[7];
    assign C[29] = G[28] | (P[28] & C[28]);
    assign C[30] = G[29] | (P[29] & G[28]) | (P[29] & P[28] & C[28]);
    assign C[31] = G[30] | (P[30] & G[29]) | (P[30] & P[29] & G[28]) | (P[30] & P[29] & P[28] & C[28]);

    // Finds Final Sum and Flags
    assign sum       = P ^ C;
    assign carry_out = C_block[8];

endmodule