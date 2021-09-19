// --------------------------------------------------------
// RISC-V: Data Memory
//
// Designing the data memory for a RV32I RISC-V processor.
//
// The memory should be able to read and write 32-bit wide
// data as per the requirements.
// --------------------------------------------------------

// --------------------------------------------------------
// Data Memory
// --------------------------------------------------------
module rv_data_mem 
#(  parameter DATA_WIDTH=64,
    parameter ADDR_WIDTH=64
)
(
  input   wire          clk,
  input   wire [ADDR_WIDTH-1:0]   dmem_addr_i,
  input   wire          dmem_wr_i,
  input   wire [DATA_WIDTH-1:0]   dmem_wr_data_i,
  output  wire [DATA_WIDTH-1:0]   dmem_data_o
);

  // --------------------------------------------------------
  // Implement memory as an 2D array
  // Memory is designed to be:
  // - Word addressable (32-bits) at every address
  // - Can contain 1K words without overflowing
  // --------------------------------------------------------
  logic [31:0] dmem [1023:0];

  // --------------------------------------------------------
  // Note: Please do not change anything above. The testbench
  // uses the module definition and memory instance to preload
  // data.
  // --------------------------------------------------------
  // --------------------------------------------------------
  // Add your logic here to read data from memory. Assume
  // that the read data is given as output irrespective of the
  // value of the `dmem_wr_i` signal.
  // --------------------------------------------------------
  assign dmem_data_o = dmem[dmem_addr_i];

  // --------------------------------------------------------
  // Add logic to write data into the memory. Remember that
  // data should only be written if the `dmem_wr_i` signal
  // is asserted.
  // --------------------------------------------------------
  always @(posedge clk) begin
    if(dmem_wr_i) begin
      dmem[dmem_addr_i] <= dmem_wr_data_i;
    end
  end

endmodule


