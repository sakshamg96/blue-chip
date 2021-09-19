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


module rv_core_single_cycle (
    input clk,
    input rst_n
);

    wire rst;

    assign rst = !rst_n;

    rv_pc  #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rv_pc_0 (
        .clk,
        .rst,
        .imm_gen_i      (imm_gen),
        .alu_zero_i     (alu_zero),
        .branch_en_i    (branch_en),
        .PCIncrSel_i    (PCIncrSel),
        .rs1_data_i     (rs1_data),
        .imem_addr_o    (imem_addr)
    );

    rv_instr_mem #(.ADDR_WIDTH(ADDR_WIDTH)) rv_instr_mem_0 (
        .imem_addr_i    (imem_addr),
        .read_instr_o   (read_instr)
    );

    rv_decode rv_decode_0 (
        .instr_i    (read_instr),
        .rs1_o      (rs1_addr),
        .rs2_o      (rs2_addr),
        .rd_o       (rd_addr),
        .op_o       (instr_op),
        .funct3_o   (funct3_val),
        .funct7_o   (funct7_val),
        .r_type_instr_o     (),
        .i_type_instr_o     (),
        .s_type_instr_o     (),
        .b_type_instr_o     (),
        .u_type_instr_o     (),
        .j_type_instr_o     (),
        .illegal_instr_o    (),
        .instr_imm_o        (instr_imm)

    );

    rv_control rv_control_0 (
        .instr_op_i     (instr_op),
        .branch_o       (branch_en),
        //.MemRead_o      (MemRead),        //Data mem is asynchronous read for now
        .MemtoReg_o     (MemtoReg),
        .ALUOp_o        (ALUOp),
        .MemWrite_o     (MemWrite),
        .ALUSrc_o       (ALUSrc),
        .RegWrite_o     (RegWrite),
        .PCIncrSel_o    (PCIncrSel)
    );

    rv_reg_file rv_reg_file_0 (
        .clk,
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

    rv_alu #(.ADDR_WDITH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) rv_alu_0 (
        .opr_a_i    (rs1_data),
        .opr_b_i    (opr_b),
        .op_sel_i   (alu_sel),
        .alu_res_o  (alu_res),
        .alu_zero_o (alu_zero)
    );

    rv_imm_gen #(.DATA_WIDTH(DATA_WIDTH)) rv_imm_gen_0 (
        .instr_imm_i    (instr_imm),
        .instr_imm_o    (imm_gen)
    );

    rv_data_mem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rv_data_mem_0 (
        .clk,
        .dmem_addr_i    (alu_res),
        .dmem_wr_i      (MemWrite),
        .dmem_wr_data_i (rs2_data),
        .dmem_data_o    (dmem_data)
    );

    //---------------------------
    //Decides which data would be written in Register file
    //--------------------------
    assign reg_wr_data = MemtoReg ? dmem_data : alu_res;
    
    //---------------------------
    //Operand of ALU 
    //--------------------------
    assign opr_b = ALUSrc ? imm_gen : rs2_data;


endmodule

