// --------------------------------------------------------
// RISC-V: Single cycle Core 
//
// The core should be able to perform all the arithmetic
// operations necessary to execute the RV32I subset of the
// instructions in single cycle.
// --------------------------------------------------------

// --------------------------------------------------------
// Core 
// --------------------------------------------------------


module rv_core_single_cycle 
#(  parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=32
)
(
    input clk,
    input rst_n,

    // Data memory interface
    output wire   [3:0]            DMEM_wr_byte_en_o,
    output wire   [ADDR_WIDTH-1:0] DMEM_addr_o,
    output wire   [DATA_WIDTH-1:0] DMEM_wr_data_o,
    input  wire   [DATA_WIDTH-1:0] DMEM_rd_data_i,
    output wire                    DMEM_wr_en,
    //output wire                    DMEM_rst_o,

    // Instruction memory interface
    //input  wire   [31:0]     boot_addr_i,
    input  wire   [31:0]     IMEM_data_i,
    output wire   [ADDR_WIDTH-1:0]     IMEM_addr_o

);

    wire rst;
    wire [DATA_WIDTH-1:0] dmem_data;

    assign rst = !rst_n;

    wire [DATA_WIDTH-1:0] imm_gen;
    wire alu_zero;
    wire branch_en;
    wire PCIncrSel;
    wire [DATA_WIDTH-1:0] rs1_data;
    wire [DATA_WIDTH-1:0] rs2_data;
    wire [ADDR_WIDTH-1:0] imem_addr;
    wire [ADDR_WIDTH-1:0] imem_addr_next;
    wire [31:0] read_instr;

    //Decode
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
    wire [6:0] instr_op;
    wire [2:0] funct3_val;
    wire [6:0] funct7_val;
    wire r_type_instr_o;
    wire i_type_instr_o;
    wire s_type_instr_o;
    wire b_type_instr;
    wire u_type_instr_o;
    wire j_type_instr_o;
    wire illegal_instr_o;
    wire [19:0] instr_imm;

    //Control
    wire MemRead;
    wire MemtoReg;
    wire [2:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;

    //Regfile
    wire [31:0] reg_wr_data;
    wire [4:0] alu_sel;

    //ALU
    reg [DATA_WIDTH-1:0] opr_b;
    wire [DATA_WIDTH-1:0] alu_res;

    rv_pc  #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rv_pc_0 (
        .clk,
        .rst,
        .imm_gen_i          (imm_gen),
        .alu_zero_i         (alu_zero),
        .branch_en_i        (branch_en),
        .PCIncrSel_i        (PCIncrSel),
        .opr_a_i            (rs1_data),
        .imem_addr_o        (imem_addr),
        .imem_addr_next_o   (imem_addr_next),
        .b_type_instr_i     (b_type_instr)
    );

    //rv_instr_mem #(.ADDR_WIDTH(ADDR_WIDTH)) rv_instr_mem_0 (
    //    .imem_addr_i    (imem_addr),
    //    .read_instr_o   (read_instr)
    //);
    assign read_instr = IMEM_data_i;
    assign IMEM_addr_o = imem_addr_next;

    rv_decode rv_decode_0 (
        .instr_i    (read_instr),
        .rs1_o      (rs1_addr),
        .rs2_o      (rs2_addr),
        .rd_o       (rd_addr),
        .op_o       (instr_op),
        .funct3_o   (funct3_val),
        .funct7_o   (funct7_val),
        .r_type_instr_o,
        .i_type_instr_o,
        .s_type_instr_o,
        .b_type_instr_o (b_type_instr),
        .u_type_instr_o,
        .j_type_instr_o,
        .illegal_instr_o,
        .instr_imm_o        (instr_imm)

    );

    //always_ff @(posedge clk) begin
    //    case(1'b1)
    //        r_type_instr_o: $display("R Type instruction detected\n");
    //        i_type_instr_o: $display("I Type instruction detected\n");
    //        s_type_instr_o: $display("S Type instruction detected\n");
    //        b_type_instr_o: $display("B Type instruction detected\n");
    //        u_type_instr_o: $display("U Type instruction detected\n");
    //        j_type_instr_o: $display("J Type instruction detected\n");
    //        illegal_instr_o: $display("Illegal instruction detected\n");
    //    endcase
    //end

    rv_control rv_control_0 (
        .instr_op_i     (instr_op),
        .branch_o       (branch_en),
        .MemRead_o      (MemRead),        //Data mem is asynchronous read for now
        .MemtoReg_o     (MemtoReg),
        .ALUOp_o        (ALUOp),
        .MemWrite_o     (MemWrite),
        .ALUSrc_o       (ALUSrc),
        .RegWrite_o     (RegWrite),
        .PCIncrSel_o    (PCIncrSel)
    );

    rv_reg_file rv_reg_file_0 (
        .clk,
        .rst,
        .rs1_addr_i (rs1_addr),
        .rs2_addr_i (rs2_addr),
        .rd_addr_i  (rd_addr),
        .wr_en_i    (RegWrite),
        .wr_data_i  (reg_wr_data),
        .rs1_data_o (rs1_data),
        .rs2_data_o (rs2_data)
    );

    rv_alu_control rv_alu_control_0 (
        .alu_op_sel_i   (ALUOp),
        .funct3_i       (funct3_val),
        .funct7_i       (funct7_val),
        .alu_sel_o      (alu_sel)
    );

    rv_alu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) rv_alu_0 (
        .opr_a_i    (rs1_data),
        .opr_b_i    (opr_b),
        .op_sel_i   (alu_sel),
        .pc_i       (imem_addr),
        .alu_res_o  (alu_res),
        .alu_zero_o (alu_zero)
    );

    rv_imm_gen #(.DATA_WIDTH(DATA_WIDTH)) rv_imm_gen_0 (
        .instr_imm_i    (instr_imm),
        .instr_imm_o    (imm_gen)
    );

    //rv_data_mem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rv_data_mem_0 (
    //    .clk,
    //    .dmem_addr_i    (alu_res),
    //    .dmem_wr_i      (MemWrite),
    //    .dmem_wr_data_i (rs2_data),
    //    .dmem_data_o    (dmem_data)
    //);

    assign DMEM_addr_o = alu_res;
    assign DMEM_wr_data_o = rs2_data;
    assign DMEM_wr_byte_en_o = {4{1'b1}};
    assign dmem_data = DMEM_rd_data_i;
    assign DMEM_wr_en = MemWrite;

    //---------------------------
    //Decides which data would be written in Register file
    //--------------------------
    assign reg_wr_data = MemtoReg ? dmem_data : alu_res;
    
    //---------------------------
    //Operand of ALU 
    //--------------------------
    assign opr_b = ALUSrc ? imm_gen : rs2_data;


endmodule

