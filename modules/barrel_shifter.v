// barrel_shifter.v
// Logarithmic Barrel Shifter for RV32I SLL / SRL / SRA
//
// Target: 100% synthesizable in Vivado (combinational only)
// Architecture: 5-layer (log2(32)) 2-to-1 MUX barrel for right shifts.
//               SLL is implemented by bit-reverse + right-logical + bit-reverse.
//               This minimizes propagation delay vs. a naive shift operator
//               or a linear (32:1 mux per bit) barrel.
//
// Ports (as specified):
//   data_in     : 32-bit value from rs1
//   shift_amount: 5-bit value (rs2[4:0] or shamt field)
//   funct3      : 3-bit (0b001 = SLL, 0b101 = SRL/SRA)
//   funct7      : 7-bit (only funct7[5] / bit 30 matters: 0=SRL, 1=SRA for funct3=101)
//   data_out    : 32-bit result
//
// Safety:
// - Purely combinational (no clocks, no always @(posedge))
// - All control paths covered with explicit conditions + default fallback (data_out = 0)
// - No incomplete if/case => no unintended latches can be inferred inside this module
// - Every bit in every layer has an explicit mux expression

`timescale 1ns / 1ps

module barrel_shifter (
    input  wire [31:0] data_in,
    input  wire [4:0]  shift_amount,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    output wire [31:0] data_out
);

  // ========================================================================
  // Instruction decode (exact per RISC-V RV32I)
  // ========================================================================
  wire is_sll = (funct3 == 3'b001);
  wire is_srl = (funct3 == 3'b101) && (funct7[5] == 1'b0);
  wire is_sra = (funct3 == 3'b101) && (funct7[5] == 1'b1);

  // ========================================================================
  // Bit reversal for SLL (left shift = reverse + logical right shift + reverse)
  // These are pure wiring (free in synthesis)
  // ========================================================================
  wire [31:0] reversed_in;
  genvar r;
  generate
    for (r = 0; r < 32; r = r + 1) begin : GEN_REVERSE_IN
      assign reversed_in[r] = data_in[31-r];
    end
  endgenerate

  // Select data for the right-shifter core and the fill bit
  wire [31:0] shift_data = is_sll ? reversed_in : data_in;
  wire        fill_bit   = is_sra ? data_in[31] : 1'b0;

  // ========================================================================
  // LOGARITHMIC BARREL SHIFTER (RIGHT DIRECTION) - 5 MUX LAYERS
  // Layer k shifts right by (1 << k) positions or passes data through.
  // Each layer consists of 32 independent 2-to-1 muxes.
  // Total: 5 layers × 32 bits = 160 muxes (plus trivial wiring).
  // ========================================================================
  wire [31:0] stage [0:5];   // stage[0] = input, stage[5] = final shifted result

  assign stage[0] = shift_data;

  genvar k, i;
  generate
    for (k = 0; k < 5; k = k + 1) begin : GEN_SHIFT_LAYER
      localparam integer SHIFT_AMT = (1 << k);   // 1, 2, 4, 8, 16

      for (i = 0; i < 32; i = i + 1) begin : GEN_MUX_PER_BIT
        // Explicit per-bit 2-to-1 MUX using generate-if so that NO
        // out-of-range bit-select expression is ever present in the
        // elaborated design (clean for Icarus + Vivado + all synthesizers).
        if (i + SHIFT_AMT < 32) begin : MUX_IN_RANGE
          assign stage[k+1][i] = shift_amount[k] ? stage[k][i + SHIFT_AMT]
                                                 : stage[k][i];
        end else begin : MUX_OUT_OF_RANGE
          assign stage[k+1][i] = shift_amount[k] ? fill_bit
                                                 : stage[k][i];
        end
      end
    end
  endgenerate

  wire [31:0] right_shifted_result = stage[5];

  // ========================================================================
  // Final bit-reverse for SLL results
  // ========================================================================
  wire [31:0] reversed_out;
  genvar ro;
  generate
    for (ro = 0; ro < 32; ro = ro + 1) begin : GEN_REVERSE_OUT
      assign reversed_out[ro] = right_shifted_result[31 - ro];
    end
  endgenerate

  // ========================================================================
  // Output selection with explicit fallback (guarantees no latch inference
  // even if this module is instantiated inside a larger always block)
  // ========================================================================
  assign data_out = is_sll ? reversed_out :
                    (is_srl || is_sra) ? right_shifted_result :
                    32'b0;   // Safe default for any other/unused funct3 combination

endmodule
