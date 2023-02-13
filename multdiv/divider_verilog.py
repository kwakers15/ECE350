f = open("divider_verilog.txt", "w+")

# module declaration
f.write("module divider(div_result, div_resultRDY, div_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);\n")
f.write("input [31:0] data_operandA, data_operandB;\ninput ctrl_MULT, ctrl_DIV, clock;\noutput [31:0] div_result;\noutput div_resultRDY, div_exception;\n\n")

f.write("// latch data operands when clk AND ctrl_DIV\n")
f.write("wire [31:0] latched_data_A, latched_data_B;\n")
f.write("register32 regA(latched_data_A, data_operandA, ctrl_DIV, 1'b0, clock);\n")
f.write("register32 regB(latched_data_B, data_operandB, ctrl_DIV, 1'b0, clock);\n\n")


f.write("// Wires for SR Latch and TFF counter\n")
f.write("wire sr_out, sr_out_bar, sr_reset, tff_q0, tff_q1, tff_q2, tff_q3, tff_q4, tff_t2, tff_t3, tff_t4, seventeen_count, eighteen_count, nineteen_count, tff_reset;\n\n")

f.write("// SR latch for counter\n")
f.write("and sr_seventeen_count_and(seventeen_count, tff_q4, ~tff_q3, ~tff_q2, ~tff_q1, tff_q0);\n")
f.write("and sr_eighteen_count_and(eighteen_count, tff_q4, ~tff_q3, ~tff_q2, tff_q1, ~tff_q0);\n")
f.write("and sr_nineteen_count_and(nineteen_count, tff_q4, ~tff_q3, ~tff_q2, tff_q1, tff_q0);\n")
f.write("or sr_reset_or(sr_reset, nineteen_count, ctrl_MULT);\n")
f.write("nor sr_nor1(sr_out, sr_out_bar, sr_reset);\n")
f.write("nor sr_not2(sr_out_bar, ctrl_DIV, sr_out);\n\n")

f.write("// T flip flop counter\n")
f.write("or tff_reset_or(tff_reset, nineteen_count, ctrl_MULT, ctrl_DIV);\n")
f.write("tff tff_0(tff_q0, 1'b1, clock, sr_out, tff_reset);\n")
f.write("tff tff_1(tff_q1, tff_q0, clock, sr_out, tff_reset);\n")
f.write("and tff_t2_and(tff_t2, tff_q1, tff_q0);\n")
f.write("tff tff_2(tff_q2, tff_t2, clock, sr_out, tff_reset);\n")
f.write("and tff_t3_and(tff_t3, tff_q0, tff_q1, tff_q2);\n")
f.write("tff tff_3(tff_q3, tff_t3, clock, sr_out, tff_reset);\n")
f.write("and tff_t4_and(tff_t4, tff_q0, tff_q1, tff_q2, tff_q3);\n")
f.write("tff tff_4(tff_q4, tff_t4, clock, sr_out, tff_reset);\n")

f.write("assign div_resultRDY = eighteen_count;\n\n")

f.write("// Check for exception by checking whether operandB = 0\n")
f.write("wire temp_div_exception;\n")
f.write("assign temp_div_exception = latched_data_B || {32{1'b0}} ? 1'b0 : 1'b1;\n\n")
f.write("dffe_ref dff(div_exception, temp_div_exception, clock, seventeen_count, tff_reset);\n\n")

f.write("// flip the sign of A and B if negative\n")
f.write("wire [31:0] negative_A, negative_B;\n")
f.write("wire [31:0] data_operandA_result, data_operandB_result;\n")
f.write("wire a_cout, b_cout;\n")
f.write("cla_32 a_result(negative_A, a_cout, ~latched_data_A, {32{1\'b0}}, 1'b1);\n")
f.write("cla_32 b_result(negative_B, b_cout, ~latched_data_B, {32{1\'b0}}, 1'b1);\n")
f.write("assign data_operandA_result = latched_data_A[31] ? negative_A : latched_data_A;\n")
f.write("assign data_operandB_result = latched_data_B[31] ? negative_B : latched_data_B;\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")


f.write("wire [63:0] left_shifted_AQ_0;\n")
f.write("assign left_shifted_AQ_0[31:0] = data_operandA_result;\n")
f.write("assign left_shifted_AQ_0[63:32] = {32{1'b0}};\n\n")

f.write("wire [31:0] M, negative_M;\n")
f.write("assign M = data_operandB_result;\n")
f.write("assign negative_M = latched_data_B[31] ? latched_data_B : negative_B;\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")


f.write("// Start of division algorithm\n")
f.write("wire add_M;\nassign add_M = 1'b0;\n")
for i in range(32):
	f.write("wire [63:0] left_shifted_AQ_"+str(i+1)+";\n")
	f.write("assign left_shifted_AQ_"+str(i+1)+" = left_shifted_AQ_"+str(i)+" << 1'b1;\n")
	f.write("wire [31:0] M_"+str(i+1)+";\nassign M_"+str(i+1)+" = add_M ? M : negative_M;\n")
	f.write("// Previous restoration + trial / Trial subtraction\n")
	f.write("wire [31:0] AQ_"+str(i+1)+"_MSB;\n")
	f.write("wire cout_"+str(i+1)+";\n")
	f.write("cla_32 trial_"+str(i+1)+"(AQ_"+str(i+1)+"_MSB, cout_"+str(i+1)+", left_shifted_AQ_"+str(i+1)+"[63:32], M_"+str(i+1)+", 1'b0);\n")
	f.write("assign add_M = AQ_"+str(i+1)+"_MSB[31] ? 1'b1 : 1'b0;\n")
	f.write("assign left_shifted_AQ_"+str(i+1)+"[63:32] = AQ_"+str(i+1)+"_MSB;\n")
	f.write("assign left_shifted_AQ_"+str(i+1)+"[0] = AQ_"+str(i+1)+"_MSB[31] ? 1'b0 : 1'b1;\n")
f.write("\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")


f.write("wire [31:0] negative_result;\nwire negative_result_cout;\n")
f.write("cla_32 negative_result_cla(negative_result, negative_result_cout, ~left_shifted_AQ_32[31:0], {32{1'b0}}, 1'b1);\n")
f.write("\nwire result_is_negative;\n")
f.write("xor result_is_negative_xor(result_is_negative, latched_data_A[31], latched_data_B[31]);\n")
f.write("wire [31:0] maybe_negative_div_result, temp_div_result;\n")
f.write("assign maybe_negative_div_result = result_is_negative ? negative_result : left_shifted_AQ_32[31:0];\n")
f.write("assign temp_div_result = div_exception ? {32{1'b0}} : maybe_negative_div_result;\n")
f.write("register32 reg_data_result(div_result, temp_div_result, seventeen_count, tff_reset, clock);\n")



f.write("endmodule")