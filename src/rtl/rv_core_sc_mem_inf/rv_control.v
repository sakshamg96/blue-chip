// --------------------------------------------------------
// RISC-V: Control Unit 
//
// Designing the control unit which will generate 
// following signals depending on instruction opcode:
//    - Branch          Signals PC whether to branch or not
//    - MemRead         Read signal for data mem
//    - MemtoReg       Decides whether 0:ALU o/p
//                                      1:data mem 
//                                      2:next PC
//                      will be written in regfile
//    - ALUOp           Generates opcode for ALU Control
//                      0: Load/Store instructions
//                      1: Branch instructions
//                      2: R Type instructions
//                      3: JAL instructions
//                      4: LUI instruction
//                      5: AUIPC instruction
//    - MemWrite        Write signal for data mem
//    - ALUSrc          2nd i/p of ALU will be from 0:reg or 1:imm
//    - RegWrite        Write signal for regfile
//
// --------------------------------------------------------

module rv_control (
    input [6:0]     instr_op_i,
    output          branch_o,
    output          MemRead_o,
    output          MemtoReg_o,
    output [2:0]    ALUOp_o,
    output          MemWrite_o,
    output          ALUSrc_o,
    output          RegWrite_o,
    output          PCIncrSel_o
);

    //---------------------------
    //
    //OPCODE values for various instruction types
    //
    //-------------------------
    localparam OPCODE_R     = 'b0110011;
    localparam OPCODE_I     = 'b0010011;
    localparam OPCODE_LOAD  = 'b0010011;
    localparam OPCODE_S     = 'b0100011;
    localparam OPCODE_B     = 'b1100011;
    localparam OPCODE_J     = 'b1101111;
    localparam OPCODE_JALR  = 'b1100111;
    localparam OPCODE_LUI   = 'b0110111;
    localparam OPCODE_AUIPC = 'b0110111;
    localparam OPCODE_ENV   = 'b1110011;

    logic [9:0] control_op;

    assign {branch_o,MemRead_o,MemtoReg_o,ALUOp_o,MemWrite_o,ALUSrc_o,RegWrite_o,PCIncrSel_o} = control_op;

    always_comb begin
        case(instr_op_i)
            OPCODE_R: begin
                control_op = {1'b0,1'b0,1'b0,3'b10,1'b0,1'b0,1'b1,1'b0}; 
            end
            OPCODE_I: begin
                control_op = {1'b0,1'b0,1'b0,3'b10,1'b0,1'b1,1'b1,1'b0}; 
            end
            OPCODE_LOAD: begin
                control_op = {1'b0,1'b1,1'b1,3'b00,1'b0,1'b1,1'b1,1'b0}; 
            end
            OPCODE_S: begin
                control_op = {1'b0,1'b0,1'b0/* 1'bx */,3'b00,1'b1,1'b1,1'b0,1'b0};      //RegWrData is actually don't care
            end
            OPCODE_B: begin
                control_op = {1'b1,1'b0,1'b0/* 1'bx */,3'b01,1'b0,1'b0,1'b0,1'b0}; 
            end
            OPCODE_J: begin
                control_op = {1'b1,1'b0,1'b0,3'b11,1'b0,1'b0,1'b1,1'b0}; 
            end
            OPCODE_JALR: begin
                control_op = {1'b1,1'b0,1'b0,3'b11,1'b0,1'b0,1'b1,1'b1}; 
            end
            OPCODE_LUI: begin
                control_op = {1'b0,1'b0,1'b0,3'b100,1'b0,1'b0,1'b1,1'b1}; 
            end
            OPCODE_AUIPC: begin
                control_op = {1'b0,1'b0,1'b0,3'b101,1'b0,1'b0,1'b1,1'b1}; 
            end
            //TODO: generate correct opcode
            OPCODE_ENV: begin
                control_op = 0; 
            end
            default: begin
                control_op = 0; 
            end

        endcase
    end

endmodule

