/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    // PC Register
    wire [31:0] PC_out, PC_in;
    wire PC_in_enable, mult, div, mult_zero_count, div_zero_count, D_X_stall;
    assign PC_in_enable = ~mult && ~div && mult_zero_count && div_zero_count && ~D_X_stall;
    register32 PC(.out(PC_out), .in(PC_in), .in_enable(PC_in_enable), .clr(reset), .clk(~clock));
    // dffe_ref PC_we(.q(PC_in_enable), .d(branch), .clk(~clock), .en(1'b1), .clr(reset));

    // Wires for SR Latch and TFF counter
    wire mult_sr_out, mult_sr_out_bar, mult_sr_reset, mult_tff_q0, mult_tff_q1, mult_tff_q2, mult_tff_t2, mult_six_count, mult_tff_reset;
    wire div_sr_out, div_sr_out_bar, div_sr_reset, div_tff_q0, div_tff_q1, div_tff_q2, div_tff_q3, div_tff_q4, div_tff_q5, div_tff_t2, div_tff_t3, div_tff_t4, div_tff_t5, div_thirty_seven_count, div_tff_reset;

    assign address_imem = PC_out;

    // PC + 1
    wire PC_1_dc1, PC_1_dc2, PC_1_dc3;
    wire [31:0] PC_plus_1, PC_plus_1_plus_N;
    cla_32 PC_adder(.data_result(PC_plus_1), .isNotEqual(PC_1_dc1), .isLessThan(PC_1_dc2), .overflow(PC_1_dc3), .data_operandA(PC_out), .data_operandB({32{1'b0}}), .Cin(1'b1));

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    // F/D Pipeline (Instruction Fetch / Decode)
    wire branch, branch_status, jump, jump_reg, F_D_enable;
    wire [31:0] F_D_instr, F_D_PC, nop, F_D_instr_in;
    assign nop = {32{1'b0}};
    assign F_D_instr_in = (branch || branch_status || jump || jump_reg || mult || div || ~mult_zero_count || ~div_zero_count) ? nop : q_imem;
    assign F_D_enable = D_X_stall ? 1'b0 : 1'b1;
    register32 F_D_instr_reg(.out(F_D_instr), .in(F_D_instr_in), .in_enable(F_D_enable), .clr(reset), .clk(~clock));
    register32 F_D_PC_reg(.out(F_D_PC), .in(PC_plus_1), .in_enable(F_D_enable), .clr(reset), .clk(~clock));

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------

    // D/X Pipeline (Decode / Execute)
    wire [4:0] opcode, rs, rt, rd;
    wire address_adder_cout;
    wire [31:0] D_X_sx_immed;
    assign D_X_sx_immed[31:17] = F_D_instr[16] ? {15{1'b1}} : {15{1'b0}};
    assign D_X_sx_immed[16:0] = F_D_instr[16:0];

    assign opcode = F_D_instr[31:27];
    assign rd = F_D_instr[26:22];
    assign rs = F_D_instr[21:17];
    assign rt = F_D_instr[16:12];

    multdiv_cla_32 address_adder(.data_result(PC_plus_1_plus_N), .Cout(address_adder_cout), .data_operandA(F_D_PC), .data_operandB(D_X_sx_immed), .Cin(1'b0));

    // decoding instruction to create control signals
    wire [31:0] operation, bypassed_dataA, bypassed_dataB, X_M_alu_out, X_M_target;
    decoder32 ctrl_decoder(.out(operation), .select(opcode), .enable(1'b1));
    wire addi_op, R_op, sw_op, lw_op, j_op, bne_op, jal_op, jr_op, blt_op, bex_op, setx_op;
    assign R_op = operation[0];
    assign addi_op = operation[5];
    assign sw_op = operation[7];
    assign lw_op = operation[8];
    assign j_op = operation[1];
    assign bne_op = operation[2];
    assign jal_op = operation[3];
    assign jr_op = operation[4];
    assign blt_op = operation[6];
    assign bex_op = operation[22];
    assign setx_op = operation[21];

    assign ctrl_readRegA = (bne_op | blt_op | jr_op) ? rd : (bex_op ? 5'b11110 : rs);
    assign ctrl_readRegB = sw_op ? rd : ((bne_op | blt_op) ? rs : rt);

    wire D_X_PC_bypassA, D_X_target_bypassA, X_M_alu_bypassA, X_M_PC_bypassA, X_M_target_bypassA, M_W_dataWrite_bypassA, M_W_PC_bypassA, M_W_target_bypassA, D_X_PC_bypassB, D_X_target_bypassB, X_M_alu_bypassB, X_M_PC_bypassB, X_M_target_bypassB, M_W_dataWrite_bypassB, M_W_PC_bypassB, M_W_target_bypassB;
    wire [31:0] D_X_target, D_X_instr;
    assign D_X_target[31:27] = {5{1'b0}};
    assign D_X_target[26:0] = D_X_instr[26:0];

    assign D_X_PC_bypassA = (bne_op | blt_op | jr_op) & D_X_instr[31:27] == 5'b00011 & F_D_instr[26:22] == 5'b11111;
    assign D_X_target_bypassA = (bex_op & D_X_instr[31:27] == 5'b10101) | ((bne_op | blt_op | jr_op) & (D_X_instr[31:27] == 5'b10101) & F_D_instr[26:22] == 5'b11110);
    assign X_M_alu_bypassA = ((bne_op | blt_op | jr_op) & ((X_M_ctrl[20] | X_M_ctrl[19]) & X_M_instr[26:22] == F_D_instr[26:22] & F_D_instr[26:22] != 5'b00000)) | (bex_op & ((X_M_ctrl[20] | X_M_ctrl[19]) & X_M_instr[26:22] == 5'b11110));
    assign X_M_target_bypassA = (bex_op & X_M_instr[31:27] == 5'b10101) | ((bne_op | blt_op | jr_op) & (X_M_instr[31:27] == 5'b10101) & F_D_instr[26:22] == 5'b11110);
    assign X_M_PC_bypassA = (bne_op | blt_op | jr_op) & X_M_instr[31:27] == 5'b00011 & F_D_instr[26:22] == 5'b11111;
    assign M_W_dataWrite_bypassA = ((bne_op | blt_op | jr_op) & ((M_W_ctrl[20] | M_W_ctrl[19] | M_W_ctrl[11]) & M_W_instr[26:22] == F_D_instr[26:22] & F_D_instr[26:22] != 5'b00000)) | (bex_op & ((M_W_ctrl[20] | M_W_ctrl[19]) & M_W_instr[26:22] == 5'b11110));
    assign M_W_PC_bypassA = (bne_op | blt_op | jr_op) & M_W_instr[31:27] == 5'b00011 & F_D_instr[26:22] == 5'b11111;
    assign M_W_target_bypassA = (bex_op & M_W_instr[31:27] == 5'b10101) | ((bne_op | blt_op | jr_op) & (M_W_instr[31:27] == 5'b10101) & F_D_instr[26:22] == 5'b11110);

    assign D_X_PC_bypassB = (bne_op | blt_op) & D_X_instr[31:27] == 5'b00011 & F_D_instr[21:17] == 5'b11111;
    assign D_X_target_bypassB = (bne_op | blt_op) & (D_X_instr[31:27] == 5'b10101) & F_D_instr[21:17] == 5'b11110;
    assign X_M_alu_bypassB = (bne_op | blt_op) & (((X_M_ctrl[20] | X_M_ctrl[19]) & X_M_instr[26:22] == F_D_instr[21:17] & F_D_instr[21:17] != 5'b00000));
    assign X_M_target_bypassB = (bne_op | blt_op) & (X_M_instr[31:27] == 5'b10101) & F_D_instr[21:17] == 5'b11110;
    assign X_M_PC_bypassB = (bne_op | blt_op) & X_M_instr[31:27] == 5'b00011 & F_D_instr[21:17] == 5'b11111;
    assign M_W_dataWrite_bypassB = (bne_op | blt_op) & (((M_W_ctrl[20] | M_W_ctrl[19] | M_W_ctrl[11]) & M_W_instr[26:22] == F_D_instr[21:17] & F_D_instr[21:17] != 5'b00000));
    assign M_W_PC_bypassB = (bne_op | blt_op) & M_W_instr[31:27] == 5'b00011 & F_D_instr[21:17] == 5'b11111;
    assign M_W_target_bypassB = (bne_op | blt_op) & (M_W_instr[31:27] == 5'b10101) & F_D_instr[21:17] == 5'b11110;

    assign bypassed_dataA = D_X_PC_bypassA ? D_X_PC : (D_X_target_bypassA ? D_X_target : (X_M_alu_bypassA ? X_M_alu_out : (X_M_target_bypassA ? X_M_target : (X_M_PC_bypassA ? X_M_PC : (M_W_dataWrite_bypassA ? data_writeReg : (M_W_PC_bypassA ? M_W_PC : (M_W_target_bypassA ? M_W_target : data_readRegA)))))));
    assign bypassed_dataB = D_X_PC_bypassB ? D_X_PC : (D_X_target_bypassB ? D_X_target : (X_M_alu_bypassB ? X_M_alu_out : (X_M_target_bypassB ? X_M_target : (X_M_PC_bypassB ? X_M_PC : (M_W_dataWrite_bypassB ? data_writeReg : (M_W_PC_bypassB ? M_W_PC : (M_W_target_bypassB ? M_W_target : data_readRegB)))))));

    wire equal, greater_than, PC_equals_T;
    thirty_two_comparator comp(.preEQ(1'b1), .preGT(1'b0), .A(bypassed_dataA), .B(bypassed_dataB), .EQ(equal), .GT(greater_than));

    // CHANGE LATER!!!! SHOULD BE MUXES TO DETERMINE PC_in
    wire [31:0] PC_target;
    wire [1:0] PC_mux_select;
    assign branch = (bne_op && ~equal) || (blt_op && ~greater_than && ~equal);
    assign branch_status = bex_op && (bypassed_dataA != {32{1'b0}});
    assign jump = j_op || jal_op;
    assign jump_reg = jr_op;
    assign PC_equals_T = branch_status || jump;
    assign PC_mux_select[1] = PC_equals_T || jump_reg;
    assign PC_mux_select[0] = branch || jump_reg;
    assign PC_target[31:27] = 5'b00000;
    assign PC_target[26:0] = F_D_instr[26:0];
    mux_4 PC_mux(PC_in, PC_mux_select, PC_plus_1, PC_plus_1_plus_N, PC_target, bypassed_dataA);

    // SR latch for mult counter
    and tff_mult_zero_count_and(mult_zero_count, ~mult_tff_q2, ~mult_tff_q1, ~mult_tff_q0);
    and sr_mult_six_count_and(mult_six_count, mult_tff_q2, mult_tff_q1, ~mult_tff_q0);
    nor mult_sr_nor1(mult_sr_out, mult_sr_out_bar, mult_six_count);
    nor mult_sr_nor2(mult_sr_out_bar, mult, mult_sr_out);

    // mult T flip flop counter
    or mult_tff_reset_or(mult_tff_reset, mult_six_count, reset);
    tff mult_tff_0(mult_tff_q0, 1'b1, ~clock, mult_sr_out, mult_tff_reset);
    tff mult_tff_1(mult_tff_q1, mult_tff_q0, ~clock, mult_sr_out, mult_tff_reset);
    and mult_tff_t2_and(mult_tff_t2, mult_tff_q1, mult_tff_q0);
    tff mult_tff_2(mult_tff_q2, mult_tff_t2, ~clock, mult_sr_out, mult_tff_reset);

    // SR latch for div counter
    and tff_div_zero_count_and(div_zero_count, ~div_tff_q5, ~div_tff_q4, ~div_tff_q3, ~div_tff_q2, ~div_tff_q1, ~div_tff_q0);
    and sr_div_thirty_seven_count_and(div_thirty_seven_count, div_tff_q5, ~div_tff_q4, ~div_tff_q3, div_tff_q2, ~div_tff_q1, div_tff_q0);
    nor div_sr_nor1(div_sr_out, div_sr_out_bar, div_thirty_seven_count);
    nor div_sr_nor2(div_sr_out_bar, div, div_sr_out);

    // div T flip flop counter
    or div_tff_reset_or(div_tff_reset, div_thirty_seven_count, reset);
    tff div_tff_0(div_tff_q0, 1'b1, ~clock, div_sr_out, div_tff_reset);
    tff div_tff_1(div_tff_q1, div_tff_q0, ~clock, div_sr_out, div_tff_reset);
    and div_tff_t2_and(div_tff_t2, div_tff_q1, div_tff_q0);
    tff div_tff_2(div_tff_q2, div_tff_t2, ~clock, div_sr_out, div_tff_reset);
    and div_tff_t3_and(div_tff_t3, div_tff_q0, div_tff_q1, div_tff_q2);
    tff div_tff_3(div_tff_q3, div_tff_t3, clock, div_sr_out, div_tff_reset);
    and div_tff_t4_and(div_tff_t4, div_tff_q0, div_tff_q1, div_tff_q2, div_tff_q3);
    tff div_tff_4(div_tff_q4, div_tff_t4, clock, div_sr_out, div_tff_reset);
    and div_tff_t5_and(div_tff_t5, div_tff_q0, div_tff_q1, div_tff_q2, div_tff_q3, div_tff_q4);
    tff div_tff_5(div_tff_q5, div_tff_t5, clock, div_sr_out, div_tff_reset);

    wire [2:0] reg_write_data;
    wire reg_we, dmem_we, alu_inB, exception;
    wire [4:0] alu_opcode;
    
    or reg_we_or(reg_we, R_op, addi_op, lw_op, jal_op, setx_op);
    assign dmem_we = sw_op;

    // reg_write_data == 000 ? take output of ALU
    // reg_write_data == 001 ? take output of data memory
    // reg_write_data == 010 ? take output of PC + 1 (from M/W pipeline register)
    // reg_write_data == 011 ? take output of target
    // reg_write_data == 100 ? take output of exception status
    // reg_write_data == 101 ? take output of multdiv
    assign reg_write_data[2] = mult | div;
    assign reg_write_data[1] = jal_op | setx_op;
    assign reg_write_data[0] = lw_op | setx_op | mult | div;

    or alu_inB_or(alu_inB, sw_op, lw_op, addi_op);

    // ALU ALWAYS ADDING IF NOT R-TYPE INSTRUCTION!!!
    assign alu_opcode = R_op ? F_D_instr[6:2] : {5{1'b0}};

    assign mult = R_op && (F_D_instr[6:2] == 5'b00110) && clock;
    assign div = R_op && (F_D_instr[6:2] == 5'b00111) && clock;

    wire [31:0] ctrl_signals;
    assign ctrl_signals[10:0] = {11{1'b0}};
    assign ctrl_signals[11] = lw_op;
    assign ctrl_signals[12] = bne_op | blt_op;
    assign ctrl_signals[13] = sw_op;
    assign ctrl_signals[14] = div;
    assign ctrl_signals[15] = mult;
    // JUST A REMINDER THAT THESE ARE THE BITS TO BE SIGN EXTENDED AND PUT INTO RSTATUS ON EXCEPTION!!!
    assign ctrl_signals[18:16] = {3{1'b0}};
    assign ctrl_signals[19] = addi_op;
    assign ctrl_signals[20] = R_op;
    assign ctrl_signals[25:21] = alu_opcode;
    assign ctrl_signals[26] = alu_inB;
    assign ctrl_signals[27] = F_D_instr == nop ? 1'b0 : dmem_we;
    assign ctrl_signals[28] = F_D_instr == nop ? 1'b0 : reg_we;
    assign ctrl_signals[31:29] = reg_write_data;

    // instruction and pc registers for pipeline
    wire [31:0] D_X_PC, D_X_reg_file_dataA, D_X_reg_file_dataB, D_X_ctrl, D_X_instr_in, D_X_ctrl_in, D_X_PC_in, D_X_A_in, D_X_B_in;
    register32 D_X_instr_reg(.out(D_X_instr), .in(D_X_instr_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_PC_reg(.out(D_X_PC), .in(D_X_PC_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_A_reg(.out(D_X_reg_file_dataA), .in(D_X_A_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_B_reg(.out(D_X_reg_file_dataB), .in(D_X_B_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_ctrl_reg(.out(D_X_ctrl), .in(D_X_ctrl_in), .in_enable(1'b1), .clr(reset), .clk(~clock));

    assign D_X_stall = (D_X_instr[31:27] == 5'b01000 & ((F_D_instr[21:17] != 5'b00000 & F_D_instr[21:17] == D_X_instr[26:22]) | (F_D_instr[16:12] != 5'b00000 & F_D_instr[16:12] == D_X_instr[26:22]) | (F_D_instr[31:27] == 5'b00100 & D_X_instr[26:22] == F_D_instr[26:22] & F_D_instr[26:22] != 5'b00000) | (F_D_instr[31:27] == 5'b10110 & D_X_instr[26:22] == 5'b11110)) & ~ctrl_signals[13]) | (X_M_instr[31:27] == 5'b01000 & ((ctrl_signals[12] & ((F_D_instr[21:17] != 5'b00000 & F_D_instr[21:17] == X_M_instr[26:22]) | (F_D_instr[26:22] != 5'b00000 & F_D_instr[26:22] == X_M_instr[26:22])) | (F_D_instr[31:27] == 5'b00100 & X_M_instr[26:22] == F_D_instr[26:22] & F_D_instr[26:22] != 5'b00000) | (F_D_instr[31:27] == 5'b10110 & X_M_instr[26:22] == 5'b11110)))) | ((ctrl_signals[12] & ((F_D_instr[21:17] != 5'b00000 & F_D_instr[21:17] == D_X_instr[26:22]) | (F_D_instr[26:22] != 5'b00000 & F_D_instr[26:22] == D_X_instr[26:22]))) | (F_D_instr[31:27] == 5'b00100 & D_X_instr[26:22] == F_D_instr[26:22] & F_D_instr[26:22] != 5'b00000) | (F_D_instr[31:27] == 5'b10110 & D_X_instr[26:22] == 5'b11110));

    assign D_X_instr_in = D_X_stall ? nop : F_D_instr;
    assign D_X_ctrl_in = D_X_stall ? nop : ctrl_signals;
    assign D_X_PC_in = F_D_PC;
    assign D_X_A_in = data_readRegA;
    assign D_X_B_in = data_readRegB;

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // X/M Pipeline (Execute / Memory)
    wire [31:0] sx_immed, alu_operandB, M_W_PC, X_M_PC, X_M_ctrl, X_M_instr, M_W_ctrl, M_W_instr, M_W_target, X_M_status, M_W_status, alu_output, multdiv_output, alu_multdiv_inputA, alu_multdiv_inputB;
    wire alu_not_equal, alu_less_than, alu_overflow, multdiv_exception, resultRDY;
    wire [3:0] ALUinA_select, ALUinB_select;
    assign sx_immed[31:17] = D_X_instr[16] ? {15{1'b1}} : {15{1'b0}};
    assign sx_immed[16:0] = D_X_instr[16:0];

    // select should never be 111
    wire a_select1, a_select2, a_select3, a_select4, a_select5, a_select6, a_select7, a_select8, b_select1, b_select2, b_select3, b_select4, b_select5, b_select6, b_select7, b_select8;
    assign a_select1 = (M_W_ctrl[20] | M_W_ctrl[19] | M_W_ctrl[11]) & M_W_instr[26:22] != {5{1'b0}} & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == M_W_instr[26:22];
    assign a_select2 = M_W_instr[31:27] == 5'b00011 & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11111;
    assign a_select3 = M_W_ctrl[31] & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11110;
    assign a_select4 = M_W_instr[31:27] == 5'b10101 & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11110;
    assign a_select5 = (X_M_ctrl[20] | X_M_ctrl[19]) & X_M_instr[26:22] != {5{1'b0}} & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == X_M_instr[26:22];
    assign a_select6 = X_M_instr[31:27] == 5'b00011 & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11111;
    assign a_select7 = X_M_ctrl[31] & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11110;
    assign a_select8 = X_M_instr[31:27] == 5'b10101 & (D_X_ctrl[20] | D_X_ctrl[26]) & D_X_instr[21:17] == 5'b11110;
    assign ALUinA_select = a_select5 ? 4'b0101 : (a_select6 ? 4'b0110 : (a_select7 ? 4'b0111 : (a_select8 ? 4'b1000 : (a_select1 ? 4'b0001 : (a_select2 ? 4'b0010 : (a_select3 ? 4'b0011 : (a_select4 ? 4'b0100 : 4'b0000)))))));
    
    // select should never be 111
    assign b_select1 = (M_W_ctrl[20] | M_W_ctrl[19] | M_W_ctrl[11]) & (M_W_instr[26:22] != {5{1'b0}}) & ((D_X_ctrl[20] & D_X_instr[16:12] == M_W_instr[26:22]) | (D_X_ctrl[13] & D_X_instr[26:22] == M_W_instr[26:22]));
    assign b_select2 = M_W_instr[31:27] == 5'b00011 & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11111) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11111));
    assign b_select3 = M_W_ctrl[31] & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11110) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11110));
    assign b_select4 = M_W_instr[31:27] == 5'b10101 & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11110) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11110));
    assign b_select5 = (X_M_ctrl[20] | X_M_ctrl[19]) & X_M_instr[26:22] != {5{1'b0}} & ((D_X_ctrl[20] & D_X_instr[16:12] == X_M_instr[26:22]) | (D_X_ctrl[13] & D_X_instr[26:22] == X_M_instr[26:22]));
    assign b_select6 = X_M_instr[31:27] == 5'b00011 & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11111) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11111));
    assign b_select7 = X_M_instr[31:27] == 5'b10101 & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11110) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11110));
    assign b_select8 = X_M_ctrl[31] & ((D_X_ctrl[20] & D_X_instr[16:12] == 5'b11110) | (D_X_ctrl[13] & D_X_instr[26:22] == 5'b11110));
    assign ALUinB_select = b_select5 ? 4'b0101 : (b_select6 ? 4'b0110 : (b_select7 ? 4'b0111 : (b_select8 ? 4'b1000 : (b_select1 ? 4'b0001 : (b_select2 ? 4'b0010 : (b_select3 ? 4'b0011 : (b_select4 ? 4'b0100 : 4'b0000)))))));

    assign X_M_target[31:27] = {5{1'b0}};
    assign X_M_target[26:0] = X_M_instr[26:0];
    assign M_W_target[31:27] = {5{1'b0}};
    assign M_W_target[26:0] = M_W_instr[26:0];
    assign X_M_status[31:3] = {29{1'b0}};
    assign X_M_status[2:0] = X_M_ctrl[18:16];
    assign M_W_status[31:3] = {29{1'b0}};
    assign M_W_status[2:0] = M_W_ctrl[18:16];

    mux_16 alu_inB_mux(.out(alu_operandB), .select(ALUinB_select), .in0(D_X_reg_file_dataB), .in1(data_writeReg), .in2(M_W_PC), .in3(M_W_status), .in4(M_W_target), .in5(X_M_alu_out), .in6(X_M_PC), .in7(X_M_target), .in8(X_M_status));
    assign alu_multdiv_inputB = D_X_ctrl[26] ? sx_immed : alu_operandB;
    
    mux_16 alu_inA_mux(.out(alu_multdiv_inputA), .select(ALUinA_select), .in0(D_X_reg_file_dataA), .in1(data_writeReg), .in2(M_W_PC), .in3(M_W_status), .in4(M_W_target), .in5(X_M_alu_out), .in6(X_M_PC), .in7(X_M_target), .in8(X_M_status));
    alu cpu_ALU(.data_operandA(alu_multdiv_inputA), .data_operandB(alu_multdiv_inputB), .ctrl_ALUopcode(D_X_ctrl[25:21]), .ctrl_shiftamt(D_X_instr[11:7]), .data_result(alu_output), .isNotEqual(alu_not_equal), .isLessThan(alu_less_than), .overflow(alu_overflow));
    multdiv cpu_MULTDIV(.data_operandA(alu_multdiv_inputA), .data_operandB(alu_multdiv_inputB), .ctrl_MULT(D_X_ctrl[15]), .ctrl_DIV(D_X_ctrl[14]), .clock(clock), .data_result(multdiv_output), .data_exception(multdiv_exception), .data_resultRDY(resultRDY));

    wire [31:0] P_W_product, P_W_ctrl, P_W_instr;
    wire P_W_multdiv;
    register32 P_W_product_reg(.out(P_W_product), .in(multdiv_output), .in_enable(resultRDY), .clr(reset), .clk(~clock));
    register32 P_W_ctrl_reg(.out(P_W_ctrl), .in(D_X_ctrl), .in_enable(~P_W_multdiv), .clr(reset), .clk(~clock));
    register32 P_W_instr_reg(P_W_instr, D_X_instr, ~P_W_multdiv, reset, ~clock);
    assign P_W_multdiv = D_X_instr == nop;

    wire [31:0] excep_added_ctrl;
    assign excep_added_ctrl[30:19] = D_X_ctrl[30:19];
    assign excep_added_ctrl[15:0] = D_X_ctrl[15:0];
    wire alu_op;
    assign alu_op = D_X_ctrl[20] || D_X_ctrl[19];
    and excep_add(excep_added_ctrl[31], alu_overflow, alu_op);
    wire mult_or_div, addi_or_sub, add_or_sub_or_div;
    assign mult_or_div = D_X_ctrl[15] || D_X_ctrl[14];
    assign addi_or_sub = D_X_ctrl[19] || (D_X_ctrl[20] && (D_X_instr[6:2] == 5'b00001));
    assign add_or_sub_or_div = D_X_ctrl[20] && ((D_X_instr[6:2] == 5'b00111) || (D_X_instr[6:2] == 5'b00001) || (D_X_instr[6:2] == 5'b00000));
    assign excep_added_ctrl[18] = excep_added_ctrl[31] && mult_or_div;
    assign excep_added_ctrl[17] = excep_added_ctrl[31] && addi_or_sub;
    assign excep_added_ctrl[16] = excep_added_ctrl[31] && add_or_sub_or_div;

    wire [31:0] X_M_reg_file_dataB, X_M_instr_in, X_M_ctrl_in;
    register32 X_M_instr_reg(.out(X_M_instr), .in(X_M_instr_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_PC_reg(.out(X_M_PC), .in(D_X_PC), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_alu_out_reg(.out(X_M_alu_out), .in(alu_output), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_reg_file_dataB_reg(.out(X_M_reg_file_dataB), .in(alu_operandB), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_ctrl_reg(.out(X_M_ctrl), .in(X_M_ctrl_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    
    assign X_M_instr_in = D_X_ctrl[15] || D_X_ctrl[14] ? nop : D_X_instr;
    assign X_M_ctrl_in = D_X_ctrl[15] || D_X_ctrl[14] ? nop : excep_added_ctrl;
    assign wren = X_M_ctrl[27];
    assign address_dmem = X_M_alu_out;
    assign data = (M_W_ctrl[11] & (M_W_instr[26:22] == X_M_instr[26:22])) ? data_writeReg : X_M_reg_file_dataB;

    // -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // M/W Pipeline (Memory / Write back)
    wire [31:0] M_W_alu_out, M_W_memdata, M_W_ctrl_in, M_W_instr_in;
    assign M_W_ctrl_in = resultRDY ? P_W_ctrl : X_M_ctrl;
    assign M_W_instr_in = resultRDY ? P_W_instr : X_M_instr;
    register32 M_W_instr_reg(.out(M_W_instr), .in(M_W_instr_in), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_PC_reg(.out(M_W_PC), .in(X_M_PC), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_alu_out_reg(.out(M_W_alu_out), .in(X_M_alu_out), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_memdata_reg(.out(M_W_memdata), .in(q_dmem), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_ctrl_reg(.out(M_W_ctrl), .in(M_W_ctrl_in), .in_enable(1'b1), .clr(reset), .clk(~clock));

    // USING 4-INPUT MUX TO CHOOSE WHETHER TO WRITE TO r31, r30, or RD
    wire [31:0] dummy_ctrl_writeReg, dummy_M_W_instr, dummy_r31, dummy_r30;
    assign dummy_M_W_instr[31:5] = {27{1'b0}};
    assign dummy_M_W_instr[4:0] = M_W_instr[26:22];
    assign dummy_r31[31:5] = {27{1'b0}};
    assign dummy_r31[4:0] = 5'b11111;
    assign dummy_r30[31:5] = {27{1'b0}};
    assign dummy_r30[4:0] = 5'b11110;
    mux_8 ctrl_writeReg_mux(dummy_ctrl_writeReg, M_W_ctrl[31:29], dummy_M_W_instr, dummy_M_W_instr, dummy_r31, dummy_r30, dummy_r30, dummy_M_W_instr, dummy_M_W_instr, dummy_M_W_instr);
    assign ctrl_writeReg = dummy_ctrl_writeReg[4:0];

    // CHANGE TO BE 4-INPUT MUX LATER (TO INCLUDE SETX AND JAL INSTRUCTIONS)
    wire [31:0] target, status;
    assign status[31:3] = {29{1'b0}};
    assign status[2:0] = M_W_ctrl[18:16];
    assign target[31:27] = {5{1'b0}};
    assign target[26:0] = M_W_instr[26:0];
    mux_8 data_writeReg_mux(.out(data_writeReg), .select(M_W_ctrl[31:29]), .in0(M_W_alu_out), .in1(M_W_memdata), .in2(M_W_PC), .in3(target), .in4(status), .in5(P_W_product), .in6(P_W_product), .in7(P_W_product));
    assign ctrl_writeEnable = M_W_ctrl[28];

    





	/* END CODE */

endmodule
