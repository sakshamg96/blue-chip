// --------------------------------------------------------
// RISC-V: Immediate Generator 
//
// Designing the Immediate generator unit for RISC-V which
// converts 12-bit signed immediate to signed 64-bit value.
//
// --------------------------------------------------------

// --------------------------------------------------------
//  Immediate generator 
// --------------------------------------------------------

module rv_imm_gen 
#(  parameter DATA_WIDTH = 64   )
(
    input [19:0]    instr_imm_i,
    output [DATA_WIDTH-1:0]   instr_imm_o
);

assign instr_imm_o = {{(DATA_WIDTH-20){instr_imm_i[19]}},instr_imm_i[19:0]};

endmodule
