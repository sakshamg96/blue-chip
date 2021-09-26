`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2021 10:15:58 AM
// Design Name: 
// Module Name: riscv-tests_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//import   RV32I_definitions::*;

// Register-Register
`define RR_ADD   0
`define RR_SUB   1
`define RR_AND   2
`define RR_OR    3
`define RR_XOR   4
`define RR_SLT   5
`define RR_SLTU  6
`define RR_SLL   7
`define RR_SRL   8
`define RR_SRA   9
 
 // Register-Immediate
`define I_ADDI   10
`define I_ANDI   11
`define I_ORI    12
`define I_XORI   13
`define I_SLTI   14
`define I_SLLI   15
`define I_SRLI   16
`define I_SRAI   17
 
 // Conditional Branches
`define B_BEQ    18
`define B_BNE    19
`define B_BLT    20
`define B_BGE    21
`define B_BLTU   22
`define B_BGEU   23

// Upper Immediate
`define UI_LUI   24
`define UI_AUIPC 25

// Jumps
`define J_JAL    26
`define J_JALR   27

// Loads
`define L_LB     28
`define L_LH     29
`define L_LW     30
`define L_LBU    31
`define L_LHU    32

// Stores
`define S_SB     33
`define S_SH     34
`define S_SW     35

// INDIVIDUAL TEST TO RUN
`define TEST_TO_RUN 0


module testbench(

    input reg         clock,
    input reg         Reset_n

);
  
    reg  [31:0] IMEM_data;
    reg  [31:0] DMEM_rd_data;

    wire [31:0] IMEM_addr;
    wire [31:0] DMEM_addr;
    wire [3:0]  DMEM_wr_byte_en;
    wire [31:0] DMEM_wr_data;
    wire        DMEM_rst;
    wire        DMEM_wr_en;
    wire        Exception;

    assign Exception = 0;


    rv_core_single_cycle UUT(
    .clk               (clock),
    .rst_n             (Reset_n),
    .DMEM_wr_byte_en_o (DMEM_wr_byte_en),
    .DMEM_addr_o       (DMEM_addr),
    .DMEM_wr_data_o    (DMEM_wr_data),
    .DMEM_rd_data_i    (DMEM_rd_data),
    .DMEM_wr_en        (DMEM_wr_en),
    //.DMEM_rst_o        (DMEM_rst),
    //.boot_addr_i       (32'b0),
    .IMEM_data_i       (IMEM_data),
    .IMEM_addr_o       (IMEM_addr)
    //.exception_o       (Exception)
    );
    
    //always#(10) clock = ~clock;     
    //initial begin
    //    Exception = 0;
    //    DMEM_rst = 0;
    //    #10 DMEM_rst = 1;
    //end
    assign DMEM_rst = Reset_n;


    // dump vcd?
    //initial begin
    //    if($test$plusargs("vcd")) begin
    //        $dumpfile("testbench.vcd");
    //        $dumpvars(0, testbench);
    //    end
    //end


    parameter MEMORY_DEPTH  = 32'hFFF;

    
    // MEMORY SIMULATION
    reg [31:0] MEMORY [0:MEMORY_DEPTH];
    integer i;
/*
    $readmemh loads program data into consecutive addresses, however 
    RISC-V uses byte-addressable memory (i.e. a word at every fourth address)
    A workaround is to ignore the lower two bits of the address.
    Do this for both program data and data memory. 

    Note that program memory and data memory are loaded from the same .hex file.
    Data memory begins at 0x2000, this can be changed by editing /Scripts/memgen.sh and
    changing the -Tdata parameter of riscv32-unknown-elf-ld.
*/
    always@(posedge clock, negedge Reset_n) begin
        if(Reset_n == 1'b0) begin
            IMEM_data <= 0;
            DMEM_rd_data <= 0;
        end
        else begin
            IMEM_data <= MEMORY[IMEM_addr[11:0]>>2];
            
            if(DMEM_rst)   DMEM_rd_data <= 0;
            else           DMEM_rd_data <= MEMORY[DMEM_addr[11:0]];

            if(DMEM_wr_en) begin
                if(DMEM_wr_byte_en[0] == 1'b1) MEMORY[DMEM_addr[11:0]][7:0]   <= DMEM_wr_data[7:0];
                if(DMEM_wr_byte_en[1] == 1'b1) MEMORY[DMEM_addr[11:0]][15:8]  <= DMEM_wr_data[15:8];
                if(DMEM_wr_byte_en[2] == 1'b1) MEMORY[DMEM_addr[11:0]][23:16] <= DMEM_wr_data[23:16];
                if(DMEM_wr_byte_en[3] == 1'b1) MEMORY[DMEM_addr[11:0]][31:24] <= DMEM_wr_data[31:24];
            end
        end

    end

    reg [5:0] TESTID_TB = 0;

    //
    // SIMULATION TASKS
    //
    export "DPI-C" function LOAD_TEST;

    function LOAD_TEST;
        input bit [5:0] TESTID;
        begin
            TESTID_TB = TESTID;
            for (i=0; i<= MEMORY_DEPTH; i=i+1) begin
                MEMORY[i] = 0;
            end
            $display("\nLoading Test with TESTID: %0d\n", TESTID);
            case(TESTID)
                
                // R-R [0:9] 
                `RR_ADD:  $readmemh("mem/hex/add.S.hex"  ,MEMORY);
                `RR_SUB:  $readmemh("mem/hex/sub.S.hex"  ,MEMORY);
                `RR_AND:  $readmemh("mem/hex/and.S.hex"  ,MEMORY);
                `RR_OR:   $readmemh("mem/hex/or.S.hex"   ,MEMORY);
                `RR_XOR:  $readmemh("mem/hex/xor.S.hex"  ,MEMORY);
                `RR_SLT:  $readmemh("mem/hex/slt.S.hex"  ,MEMORY);
                `RR_SLTU: $readmemh("mem/hex/sltu.S.hex" ,MEMORY);
                `RR_SLL:  $readmemh("mem/hex/sll.S.hex"  ,MEMORY);
                `RR_SRL:  $readmemh("mem/hex/srl.S.hex"  ,MEMORY);
                `RR_SRA:  $readmemh("mem/hex/sra.S.hex"  ,MEMORY);
        
                // R-I [10:17]
                `I_ADDI:  $readmemh("mem/hex/addi.S.hex" ,MEMORY);
                `I_ANDI:  $readmemh("mem/hex/andi.S.hex" ,MEMORY);
                `I_ORI:   $readmemh("mem/hex/ori.S.hex"  ,MEMORY);
                `I_XORI:  $readmemh("mem/hex/xori.S.hex" ,MEMORY);
                `I_SLTI:  $readmemh("mem/hex/slti.S.hex" ,MEMORY);
                `I_SLLI:  $readmemh("mem/hex/slli.S.hex" ,MEMORY);
                `I_SRLI:  $readmemh("mem/hex/srli.S.hex" ,MEMORY);
                `I_SRAI:  $readmemh("mem/hex/srai.S.hex" ,MEMORY);
                
                // Conditional Branches [18:23]
                `B_BEQ:   $readmemh("mem/hex/beq.S.hex"  ,MEMORY);
                `B_BNE:   $readmemh("mem/hex/bne.S.hex"  ,MEMORY);
                `B_BLT:   $readmemh("mem/hex/blt.S.hex"  ,MEMORY);
                `B_BGE:   $readmemh("mem/hex/bge.S.hex"  ,MEMORY);
                `B_BLTU:  $readmemh("mem/hex/bltu.S.hex" ,MEMORY);
                `B_BGEU:  $readmemh("mem/hex/bgeu.S.hex" ,MEMORY);
    
                // Upper Imm [24:25]
                `UI_LUI:  $readmemh("mem/hex/lui.S.hex"  ,MEMORY);
                `UI_AUIPC:$readmemh("mem/hex/auipc.S.hex",MEMORY);
    
                // Jumps [26:27]
                `J_JAL:   $readmemh("mem/hex/jal.S.hex"  ,MEMORY);
                `J_JALR:  $readmemh("mem/hex/jalr.S.hex" ,MEMORY);
    
                // Loads [28:32]
                `L_LB:    $readmemh("mem/hex/lb.S.hex"   ,MEMORY);
                `L_LH:    $readmemh("mem/hex/lh.S.hex"   ,MEMORY);
                `L_LW:    $readmemh("mem/hex/lw.S.hex"   ,MEMORY);
                `L_LBU:   $readmemh("mem/hex/lbu.S.hex"  ,MEMORY);
                `L_LHU:   $readmemh("mem/hex/lhu.S.hex"  ,MEMORY);
                
                // Stores [33:35]
                `S_SB:    $readmemh("mem/hex/sb.S.hex"   ,MEMORY);
                `S_SH:    $readmemh("mem/hex/sh.S.hex"   ,MEMORY);
                `S_SW:    $readmemh("mem/hex/sw.S.hex"   ,MEMORY);

            endcase
            //$writememh("mem_out.txt"  ,MEMORY);
        end
    endfunction // LOAD_TEST

    export "DPI-C" function EVAL_TEST;   
    //integer t;
    function EVAL_TEST;
        input bit [5:0] TESTID;
        output bit PASS_ST;
        begin
            PASS_ST = 0;
            
            // Check if test pass
            // pass condition: GP=1 , A7=93, A0=0
            if((UUT.rv_reg_file_0.regfile[3] == 1) &&   
               (UUT.rv_reg_file_0.regfile[17] == 93) && 
               (UUT.rv_reg_file_0.regfile[10] == 0))    
            begin
                $display("\nTEST PASSED; ID: %0d", TESTID);
                PASS_ST = 1;
            end else if (Exception == 1) begin
                $display("EXCEPTION ASSERTED, TEST FAILED");
                $display("FAILED TEST ID: %0d", TESTID);
                $finish;
            end
        end
    endfunction // EVAL_TEST


    //
    // TESTBENCH BEGIN
    //
    //integer j;
    //initial begin
    //    Reset_n = 0;
    //    #100;

    //    if($test$plusargs("runall")) begin
    //        $display("Running all tests.");
    //        for(j=`RR_ADD; j<=`S_SW; j=j+1) begin
    //            $display("***********************************");
    //            $display("Running Test ID: %0d", j);
    //            LOAD_TEST(j);
    //            #100;
    //            EVAL_TEST(j);

    //        end
    //        $display("");
    //        $display("***********************************");
    //        $display("ALL TESTS PASSED !");
    //        $finish;

    //    end

    //    else begin
    //        $display("Running Test ID: %0d", `TEST_TO_RUN);
    //        LOAD_TEST(`TEST_TO_RUN);
    //        EVAL_TEST(`TEST_TO_RUN);
    //        $display("***********************************");
    //        $display("TEST PASSED !");
    //        $finish;
    //    end
    //end

   // Print some stuff as an example
   initial begin
      if ($test$plusargs("trace") != 0) begin
         $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
         $dumpfile("logs/vlt_dump.vcd");
         $dumpvars();
      end
      $display("[%0t] Model running...\n", $time);
   end


endmodule
