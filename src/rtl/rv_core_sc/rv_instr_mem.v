
// --------------------------------------------------------
// RISC-V: Instruction Memory
//
// Designing the instruction fetch unit for RISC-V which
// implements a memory from where the stored instructions
// are read and given as outputs.
//
// The memory should be able to return the instruction
// stored at the given input address.
// --------------------------------------------------------

// --------------------------------------------------------
// Instruction Memory
// --------------------------------------------------------

module rv_instr_mem 
#(  parameter ADDR_WIDTH=64 )
(
  input   wire [ADDR_WIDTH-1:0] imem_addr_i,
  output  wire [31:0]           read_instr_o
);

  // --------------------------------------------------------
  // Implement memory as an 2D array
  // Memory is designed to be:
  // - Word addressable (32-bits) at every address
  // - Can contain 1K words without overflowing
  // - Assume that the memory is preloaded with instructions
  // --------------------------------------------------------
  logic [31:0] imem [(2**ADDR_WIDTH) - 1:0];

  // --------------------------------------------------------
  // Note: Please do not change anything above. The testbench
  // uses the module definition and memory instance to preload
  // instructions.
  // --------------------------------------------------------
  // --------------------------------------------------------
  // Add your logic here to read instruction from memory
  // --------------------------------------------------------
 assign read_instr_o = imem[imem_addr_i];
  
endmodule

