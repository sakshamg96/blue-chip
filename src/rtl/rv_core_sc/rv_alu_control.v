// --------------------------------------------------------
// RISC-V: ALU Control unit 
//
// The ALU Control unit should be able to generate required 
// ALU selection bits depending on ALU Op bits and funct3
// and funct7 fields.
// --------------------------------------------------------

// --------------------------------------------------------
// ALU Control Unit
// --------------------------------------------------------

module rv_alu_control (
    input [2:0] alu_op_sel_i,
    input [2:0] funct3_i,
    input [6:0] funct7_i,
    output [3:0] alu_sel_o
);

    logic [3:0] alu_sel;

    always_comb begin
        case(alu_op_sel_i)
            3'b00: begin
                alu_sel = OP_ADD;
            end
            3'b01: begin
                case(funct3_i)
                    3'h0: begin
                        alu_sel = OP_EQL;
                    end
                    3'h1: begin
                        alu_sel = OP_NEQL;
                    end
                    3'h4: begin
                        alu_sel = OP_SLT;
                    end
                    3'h5: begin
                        alu_sel = OP_SGT;
                    end
                    3'h6: begin
                        alu_sel = OP_ULT;
                    end
                    3'h7: begin
                        alu_sel = OP_UGT;
                    end
                    default: begin
                        alu_sel = 0;
                    end
                endcase
            end
            3'b10: begin
                case(funct7_i)
                    7'h0: begin
                        case(funct3_i)
                            3'h0: begin
                                alu_sel = OP_ADD;
                            end
                            3'h1: begin
                                alu_sel = OP_SLL;
                            end
                            3'h2: begin
                                alu_sel = OP_SLT;
                            end
                            3'h3: begin
                                alu_sel = OP_ULT;
                            end
                            3'h4: begin
                                alu_sel = OP_XOR;
                            end
                            3'h5: begin
                                alu_sel = OP_SRL;
                            end
                            3'h6: begin
                                alu_sel = OP_OR;
                            end
                            3'h7: begin
                                alu_sel = OP_AND;
                            end
                        endcase
                    end
                    7'h2: begin
                        case(funct3_i) 
                            3'h0: begin
                                alu_sel = OP_SUB;
                            end
                            3'h5: begin
                                alu_sel = OP_SRA;
                            end
                            default: begin
                                alu_sel = 0;
                            end
                        endcase
                    end
                endcase
            end
            3'b11: begin
                alu_res = OP_JAL;
            end
            3'b100: begin
                alu_res = OP_LUI;
            end
            3'b101: begin
                alu_res = OP_AUIPC;
            end
        endcase
    end

endmodule
