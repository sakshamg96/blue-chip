// --------------------------------------------------------
// RISC-V: Arithmetic Logical Unit
//
// Designing the ALU for the RV32I based RISC-V processor.
// The ALU should be able to perform all the arithmetic
// operations necessary to execute the RV32I subset of the
// instructions.
// --------------------------------------------------------

// --------------------------------------------------------
// Arithmetic Logical Unit (ALU)
// --------------------------------------------------------

`include "instr_op.vh"
module rv_alu 
#(  parameter DATA_WIDTH=64,
    parameter ADDR_WIDTH=64
)
(
  input   wire [DATA_WIDTH-1:0] opr_a_i,            // Operand 1
  input   wire [DATA_WIDTH-1:0] opr_b_i,            // Operand 2
  input   wire [4:0]            op_sel_i,           // Opcode select
  input        [ADDR_WIDTH-1:0] pc_i,               // Program Counter
  output  wire [DATA_WIDTH-1:0] alu_res_o,          // ALU output
  output  wire                  alu_zero_o          // Result of relational operation
);

  // --------------------------------------------------------
  // Local parameters
  // These parameters define the encodings of the `op_sel_i`
  // input to the ALU. Using parameters is better as it eases
  // debugging and helps in maintaining the code.
  // --------------------------------------------------------
  //localparam OP_ADD  = 5'h0;
  //localparam OP_SUB  = 5'h1;
  //localparam OP_XOR  = 5'h2;
  //localparam OP_OR   = 5'h3;
  //localparam OP_AND  = 5'h4;
  //localparam OP_SLL  = 5'h5;
  //localparam OP_SRL  = 5'h6;
  //localparam OP_SRA  = 5'h7;

  //localparam OP_SLT  = 5'h8;
  //localparam OP_SGT  = 5'h9;
  //localparam OP_EQL  = 5'hA;
  //localparam OP_NEQL = 5'hB;
  //localparam OP_ULT  = 5'hC;
  //localparam OP_UGT  = 5'hD;

  //localparam OP_JAL    = 5'hE;
  //localparam OP_LUI    = 5'hF;
  //localparam OP_AUIPC  = 5'h10;

  // --------------------------------------------------------
  // Use a `signed` version of the two operands as well.
  // This would help in easily computing operations which
  // operate on signed inputs (like SLT, SGT)
  // --------------------------------------------------------
  wire signed [DATA_WIDTH-1:0] sign_opr_a;
  wire signed [DATA_WIDTH-1:0] sign_opr_b;

  // --------------------------------------------------------
  // Declaring an internal signal to hold the ALU result.
  // This would be later assigned to the actual output
  // --------------------------------------------------------
  logic [DATA_WIDTH-1:0] alu_res;
  logic alu_zero;

  // --------------------------------------------------------
  // Signed opeartions can simply be assigned to the current
  // inputs. The `>>>` operator or the `>` operator would
  // recognise these as signed numbers.
  // --------------------------------------------------------
  assign sign_opr_a = opr_a_i;
  assign sign_opr_b = opr_b_i;

  // --------------------------------------------------------
  // The ALU result would depend on the value of the `op_sel`
  // input to the ALU. It would be helpful to implement this
  // as a case statement covering all the possible values for
  // the `op_sel` input.
  // It would be a good time to quickly review the operation
  // performed by each of the instruction from the RISC-V
  // ISA. See section "2.4 Integer Computational Instructions"
  // --------------------------------------------------------
  always@(*) begin
    alu_zero = 1'b0;
    alu_res = 'b0;
    case (op_sel_i)
      OP_ADD : alu_res = opr_a_i + opr_b_i;
      OP_SUB : alu_res = opr_a_i - opr_b_i;
      OP_XOR : alu_res = opr_a_i ^ opr_b_i;
      OP_OR  : alu_res = opr_a_i | opr_b_i;
      OP_AND : alu_res = opr_a_i & opr_b_i;
      OP_SLL : alu_res = opr_a_i << opr_b_i[4:0];
      OP_SRL : alu_res = opr_a_i >> opr_b_i[4:0];
      OP_SRA : alu_res = sign_opr_a >>> opr_b_i[4:0];

      //OP_SLT : alu_res = {31'h0, sign_opr_a <= sign_opr_b};
      //OP_SGT : alu_res = {31'h0, sign_opr_a >= sign_opr_b};
      //OP_EQL : alu_res = {31'h0, opr_a_i == opr_b_i};
      //OP_NEQL : alu_res = {31'h0, opr_a_i != opr_b_i};
      //OP_ULT : alu_res = {31'h0, opr_a_i <= opr_b_i};
      //OP_UGT : alu_res = {31'h0, opr_a_i >= opr_b_i};

      OP_SLT : alu_zero = sign_opr_a <= sign_opr_b;
      OP_SGT : alu_zero = sign_opr_a >= sign_opr_b;
      OP_EQL : alu_zero = opr_a_i == opr_b_i;
      OP_NEQL : alu_zero = opr_a_i != opr_b_i;
      OP_ULT : alu_zero = opr_a_i <= opr_b_i;
      OP_UGT : alu_zero = opr_a_i >= opr_b_i;

      OP_JAL : alu_res = pc_i + 4;
      OP_LUI : alu_res = opr_b_i << 12;
      OP_AUIPC : alu_res = pc_i + (opr_b_i << 12);
      default: alu_res = 'h0;
    endcase
  end

  // --------------------------------------------------------
  // Output assignment
  // --------------------------------------------------------
  assign alu_res_o = alu_res;
  assign alu_zero_o = alu_zero;

endmodule

