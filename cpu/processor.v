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
    register32 PC(.out(PC_out), .in(PC_in), .in_enable(1'b1), .clr(reset), .clk(clock));
    
    assign address_imem = PC_out;

    // PC + 1
    wire PC_1_dc1, PC_1_dc2, PC_1_dc3;
    wire [31:0] PC_plus_1;
    cla_32 PC_adder(.data_result(PC_plus_1), .isNotEqual(PC_1_dc1), .isLessThan(PC_1_dc2), .overflow(PC_1_dc3), .data_operandA(PC_out), .data_operandB({32{1'b0}}), .Cin(1'b1));
    
    // CHANGE LATER!!!! SHOULD BE MUXES TO DETERMINE PC_in
    assign PC_in = PC_plus_1;

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    // F/D Pipeline (Instruction Fetch / Decode)
    wire [31:0] F_D_instr, F_D_PC;
    register32 F_D_instr_reg(.out(F_D_instr), .in(q_imem), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 F_D_PC_reg(.out(F_D_PC), .in(PC_plus_1), .in_enable(1'b1), .clr(reset), .clk(~clock));

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------

    // D/X Pipeline (Decode / Execute)
    wire [4:0] opcode, rs, rt, rd;
    
    assign opcode = F_D_instr[31:27];
    assign rd = F_D_instr[26:22];
    assign rs = F_D_instr[21:17];
    assign rt = F_D_instr[16:12];



    // decoding instruction to create control signals
    wire [31:0] operation;
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

    assign ctrl_readRegA = rs;
    assign ctrl_readRegB = sw_op ? rd : rt;


    wire [1:0] reg_write_data;
    wire reg_we, dmem_we, alu_inB, exception;
    wire [4:0] alu_opcode;
    
    or reg_we_or(reg_we, R_op, addi_op, lw_op, jal_op, setx_op);
    assign dmem_we = sw_op;

    // reg_write_data == 00 ? take output of ALU
    // reg_write_data == 01 ? take output of data memory
    // reg_write_data == 10 ? take output of PC + 1 (from M/W pipeline register)
    // reg_write_data == 11 ? take output of target (FROM PC + 1 OR PC???????????)
    assign reg_write_data[1] = jal_op | setx_op;
    assign reg_write_data[0] = lw_op | setx_op;

    or alu_inB_or(alu_inB, sw_op, lw_op, addi_op);

    // ALU ALWAYS ADDING IF NOT R-TYPE INSTRUCTION!!!
    assign alu_opcode = R_op ? F_D_instr[6:2] : {5{1'b0}};

    wire [31:0] ctrl_signals;
    assign ctrl_signals[15:0] = {16{1'b0}};
    // JUST A REMINDER THAT THESE ARE THE BITS TO BE SIGN EXTENDED AND PUT INTO RSTATUS ON EXCEPTION!!!
    assign ctrl_signals[18:16] = {3{1'b0}};
    assign ctrl_signals[19] = 1'b0;
    assign ctrl_signals[20] = addi_op;
    assign ctrl_signals[21] = R_op;
    assign ctrl_signals[26:22] = alu_opcode;
    assign ctrl_signals[27] = alu_inB;
    assign ctrl_signals[28] = dmem_we;
    assign ctrl_signals[29] = reg_we;
    assign ctrl_signals[31:30] = reg_write_data;

    // instruction and pc registers for pipeline
    wire [31:0] D_X_instr, D_X_PC, reg_file_dataA, D_X_reg_file_dataB, D_X_ctrl;
    register32 D_X_instr_reg(.out(D_X_instr), .in(F_D_instr), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_PC_reg(.out(D_X_PC), .in(F_D_PC), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_A_reg(.out(reg_file_dataA), .in(data_readRegA), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_B_reg(.out(D_X_reg_file_dataB), .in(data_readRegB), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 D_X_ctrl_reg(.out(D_X_ctrl), .in(ctrl_signals), .in_enable(1'b1), .clr(reset), .clk(~clock));

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // X/M Pipeline (Execute / Memory)
    wire [31:0] sx_immed, alu_operandB, alu_output;
    wire alu_not_equal, alu_less_than, alu_overflow;
    assign sx_immed[31:17] = D_X_instr[16] ? {15{1'b1}} : {15{1'b0}};
    assign sx_immed[16:0] = D_X_instr[16:0];
    assign alu_operandB = D_X_ctrl[27] ? sx_immed : D_X_reg_file_dataB;
    alu cpu_ALU(.data_operandA(reg_file_dataA), .data_operandB(alu_operandB), .ctrl_ALUopcode(D_X_ctrl[26:22]), .ctrl_shiftamt(D_X_instr[11:7]), .data_result(alu_output), .isNotEqual(alu_not_equal), .isLessThan(alu_less_than), .overflow(alu_overflow));
    // multdiv cpu_MULTDIV(.data_operandA(), .data_operandB(), .ctrl_MULT(), .ctrl_DIV(), .clock(), .data_result(), .data_exception(), .data_resultRDY());

    wire [31:0] excep_added_ctrl;
    assign excep_added_ctrl[31:20] = D_X_ctrl[31:20];
    assign excep_added_ctrl[15:0] = {16{1'b0}};
    wire alu_op;
    assign alu_op = D_X_ctrl[21] || D_X_ctrl[20];
    and excep_add(excep_added_ctrl[19], alu_overflow, alu_op);
    wire mult_or_div, addi_or_sub, add_or_sub_or_div;
    assign mult_or_div = D_X_ctrl[21] && ((D_X_instr[6:2] == 5'b00110) || (D_X_instr[6:2] == 5'b00111));
    assign addi_or_sub = D_X_ctrl[20] || (D_X_ctrl[21] && (D_X_instr[6:2] == 5'b00001));
    assign add_or_sub_or_div = D_X_ctrl[21] && ((D_X_instr[6:2] == 5'b00111) || (D_X_instr[6:2] == 5'b00001) || (D_X_instr[6:2] == 5'b00000));
    assign excep_added_ctrl[18] = excep_added_ctrl[19] && mult_or_div;
    assign excep_added_ctrl[17] = excep_added_ctrl[19] && addi_or_sub;
    assign excep_added_ctrl[16] = excep_added_ctrl[19] && add_or_sub_or_div;

    wire [31:0] X_M_instr, X_M_PC, X_M_alu_out, X_M_reg_file_dataB, X_M_ctrl;
    register32 X_M_instr_reg(.out(X_M_instr), .in(D_X_instr), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_PC_reg(.out(X_M_PC), .in(D_X_PC), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_alu_out_reg(.out(X_M_alu_out), .in(alu_output), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_reg_file_dataB_reg(.out(X_M_reg_file_dataB), .in(D_X_reg_file_dataB), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 X_M_ctrl_reg(.out(X_M_ctrl), .in(excep_added_ctrl), .in_enable(1'b1), .clr(reset), .clk(~clock));

    assign wren = X_M_ctrl[28];
    assign address_dmem = X_M_alu_out;
    assign data = X_M_reg_file_dataB;

    // -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // M/W Pipeline (Memory / Write back)
    wire [31:0] M_W_instr, M_W_PC, M_W_alu_out, M_W_memdata, M_W_ctrl;
    register32 M_W_instr_reg(.out(M_W_instr), .in(X_M_instr), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_PC_reg(.out(M_W_PC), .in(X_M_PC), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_alu_out_reg(.out(M_W_alu_out), .in(X_M_alu_out), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_memdata_reg(.out(M_W_memdata), .in(q_dmem), .in_enable(1'b1), .clr(reset), .clk(~clock));
    register32 M_W_ctrl_reg(.out(M_W_ctrl), .in(X_M_ctrl), .in_enable(1'b1), .clr(reset), .clk(~clock));

    // USING 4-INPUT MUX TO CHOOSE WHETHER TO WRITE TO r31, r30, or RD
    wire [31:0] dummy_ctrl_writeReg, dummy_M_W_instr, dummy_r31, dummy_r30;
    assign dummy_M_W_instr[31:5] = {27{1'b0}};
    assign dummy_M_W_instr[4:0] = M_W_instr[26:22];
    assign dummy_r31[31:5] = {27{1'b0}};
    assign dummy_r31[4:0] = 5'b11111;
    assign dummy_r30[31:5] = {27{1'b0}};
    assign dummy_r30[4:0] = 5'b11110;
    wire [1:0] writeCtrl;
    assign writeCtrl = M_W_ctrl[19] ? 2'b11 : M_W_ctrl[31:30];
    mux_4 ctrl_writeReg_mux(dummy_ctrl_writeReg, writeCtrl, dummy_M_W_instr, dummy_M_W_instr, dummy_r31, dummy_r30);
    assign ctrl_writeReg = dummy_ctrl_writeReg[4:0];

    // CHANGE TO BE 4-INPUT MUX LATER (TO INCLUDE SETX AND JAL INSTRUCTIONS)
    wire [31:0] dummy_PC_plus_1, target, status;
    wire [2:0] data_writeCtrl;
    assign status[31:3] = {29{1'b0}};
    assign status[2:0] = M_W_ctrl[18:16];
    assign dummy_PC_plus_1 = {32{1'b0}};
    assign target[31:27] = {5{1'b0}};
    assign target[26:0] = M_W_instr[26:0];
    assign data_writeCtrl[2] = M_W_ctrl[19];
    assign data_writeCtrl[1:0] = M_W_ctrl[31:30];
    mux_8 data_writeReg_mux(.out(data_writeReg), .select(data_writeCtrl), .in0(M_W_alu_out), .in1(M_W_memdata), .in2(dummy_PC_plus_1), .in3(target), .in4(status), .in5(status), .in6(status), .in7(status));
    assign ctrl_writeEnable = M_W_ctrl[29];

    





	/* END CODE */

endmodule
