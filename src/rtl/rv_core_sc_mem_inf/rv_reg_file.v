// --------------------------------------------------------
// RISC-V: Register File
//
// Designing the register file for RISC-V processor.
// The register file would implement the 32 architectural
// registers, each being XLEN wide. For our processor
// each of the register would be 32-bit wide.
// --------------------------------------------------------

// --------------------------------------------------------
// Register File
// --------------------------------------------------------

module rv_reg_file (
  input   wire          clk,
  input   wire [4:0]    rs1_addr_i,
  input   wire [4:0]    rs2_addr_i,
  input   wire [4:0]    rd_addr_i,
  input   wire          wr_en_i,
  input   wire [31:0]   wr_data_i,
  output  wire [31:0]   rs1_data_o,
  output  wire [31:0]   rs2_data_o
);

  // --------------------------------------------------------
  // Implement register file as an 2D array
  // Register file should be:
  // - Contain the 32 architectural registers
  // - Each register should be 32-bit wide
  // - Register X0 should always return 0
  // --------------------------------------------------------
  logic [31:0] regfile [31:0];

  // --------------------------------------------------------
  // Note: Please do not change anything above. The testbench
  // uses the module definition and regfile instance to preload
  // values to the registers.
  // --------------------------------------------------------
  // --------------------------------------------------------
  // Add your logic here
  // --------------------------------------------------------
  reg [31:0] rs1_data;
  reg [31:0] rs2_data;
  
  always_comb begin
    rs1_data = regfile[rs1_addr_i];
    rs2_data = regfile[rs2_addr_i];
  end
  
  always_ff @(posedge clk) begin
    if(wr_en_i & rd_addr_i != 0) begin
      regfile[rd_addr_i] <= wr_data_i;
    end
  end
  

  // Read data should be returned on the same cycle
  // Handle reads to X0 register here. Those should
  // always return 0. The `rs1_addr_i` and `rs2_addr_i`
  // are the read addresses for the two source registers
  // respectively.

  assign rs1_data_o = rs1_data;
  assign rs2_data_o = rs2_data;

  // Write to the register file should use the `rd_addr_i`
  // signal for the register file address and the `wr_en_i`
  // signal as the enable

endmodule


