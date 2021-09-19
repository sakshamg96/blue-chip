`ifndef INSTR_OP_GUARD
`define INSTR_OP_GUARD

localparam OP_ADD  = 5'h0;
localparam OP_SUB  = 5'h1;
localparam OP_XOR  = 5'h2;
localparam OP_OR   = 5'h3;
localparam OP_AND  = 5'h4;
localparam OP_SLL  = 5'h5;
localparam OP_SRL  = 5'h6;
localparam OP_SRA  = 5'h7;

localparam OP_SLT  = 5'h8;
localparam OP_SGT  = 5'h9;
localparam OP_EQL  = 5'hA;
localparam OP_NEQL = 5'hB;
localparam OP_ULT  = 5'hC;
localparam OP_UGT  = 5'hD;

localparam OP_JAL    = 5'hE;
localparam OP_LUI    = 5'hF;
localparam OP_AUIPC  = 5'h10;
`endif
