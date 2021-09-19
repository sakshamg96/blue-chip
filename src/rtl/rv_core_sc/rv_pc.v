// --------------------------------------------------------
// RISC-V: Program Counter 
//
// Designing the program counter unit for RISC-V which
// generates correct byte address for instruction memory
// according to branch and non-branch instructions.
//
// --------------------------------------------------------

// --------------------------------------------------------
//  Program Counter 
// --------------------------------------------------------


module rv_pc 
#(  parameter DATA_WIDTH=64,
    parameter ADDR_WIDTH=64,
)
(
    input                       clk,
    input                       rst,
    input [DATA_WIDTH-1:0]      imm_gen_i,          // Immediate fetched from instruction
    input                       alu_zero_i,      // ALU condition check
    input                       branch_en_i,        // 1: Instruction fetched is a branch instruction else PC+4
    input                       PCIncrSel_i,        // Select between jal and jalr
    input  [DATA_WIDTH-1:0]     opr_a_i,            // ALU operand 1 for jal and jalr instructions
    output [ADDR_WIDTH-1:0]     imem_addr_o         // Instruction memory address
);

    reg [ADDR_WIDTH-1:0] instr_cntr;
    wire [ADDR_WIDTH-1:0] instr_cntr_c;

    always @(posedge clk)
    begin
        if(rst) begin
            instr_cntr <= 0;
        end
        else begin
            instr_cntr <= instr_cntr_c;
        end
    end

    wire [ADDR_WIDTH-1:0] PCIncr;

    assign PCIncr = PCIncrSel_i ? (opr_a_i + (imm_gen_i<<1)) : (instr_cntr + (imm_gen_i<<1));

    assign instr_cntr_c = (branch_en_i & alu_zero_i) ? PCIncr : (instr_cntr + 4);

endmodule
