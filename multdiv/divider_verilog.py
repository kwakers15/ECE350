f = open("divider_verilog.txt", "w+")

# module declaration
f.write("module divider(div_result, div_resultRDY, div_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);\n")
f.write("input [31:0] data_operandA, data_operandB;\ninput ctrl_MULT, ctrl_DIV, clock;\noutput [31:0] div_result;\noutput div_resultRDY, div_exception;\n\n")

f.write("// latch data operands when clk AND ctrl_DIV\n")
f.write("wire [31:0] latched_data_A, latched_data_B;\n")
f.write("register32 regA(latched_data_A, data_operandA, ctrl_DIV, 1'b0, clock);\n")
f.write("register32 regB(latched_data_B, data_operandB, ctrl_DIV, 1'b0, clock);\n\n")


f.write("// Wires for SR Latch and TFF counter\n")
f.write("wire sr_out, sr_out_bar, sr_reset, tff_q0, tff_q1, tff_q2, tff_q3, tff_q4, tff_q5, tff_t2, tff_t3, tff_t4, tff_t5, zero_count, one_count, thirty_four_count, thirty_five_count, thirty_six_count, tff_reset;\n\n")

f.write("// SR latch for counter\n")
f.write("or sr_reset_or(sr_reset, thirty_six_count, ctrl_MULT);\n")
f.write("nor sr_nor1(sr_out, sr_out_bar, sr_reset);\n")
f.write("nor sr_not2(sr_out_bar, ctrl_DIV, sr_out);\n\n")

f.write("// T flip flop counter\n")
f.write("or tff_reset_or(tff_reset, thirty_six_count, ctrl_MULT, ctrl_DIV);\n")
f.write("tff tff_0(tff_q0, 1'b1, clock, sr_out, tff_reset);\n")
f.write("tff tff_1(tff_q1, tff_q0, clock, sr_out, tff_reset);\n")
f.write("and tff_t2_and(tff_t2, tff_q1, tff_q0);\n")
f.write("tff tff_2(tff_q2, tff_t2, clock, sr_out, tff_reset);\n")
f.write("and tff_t3_and(tff_t3, tff_q0, tff_q1, tff_q2);\n")
f.write("tff tff_3(tff_q3, tff_t3, clock, sr_out, tff_reset);\n")
f.write("and tff_t4_and(tff_t4, tff_q0, tff_q1, tff_q2, tff_q3);\n")
f.write("tff tff_4(tff_q4, tff_t4, clock, sr_out, tff_reset);\n")
f.write("and tff_t5_and(tff_t5, tff_q0, tff_q1, tff_q2, tff_q3, tff_q4);\n")
f.write("tff tff_5(tff_q5, tff_t5, clock, sr_out, tff_reset);\n")
f.write("and tff_zero_count_and(zero_count, ~tff_q5, ~tff_q4, ~tff_q3, ~tff_q2, ~tff_q1, ~tff_q0);\n")
f.write("and tff_one_count_and(one_count, ~tff_q5, ~tff_q4, ~tff_q3, ~tff_q2, ~tff_q1, tff_q0);\n")
f.write("and tff_thirty_four_count_and(thirty_four_count, tff_q5, ~tff_q4, ~tff_q3, ~tff_q2, tff_q1, ~tff_q0);\n")
f.write("and tff_thirty_five_count_and(thirty_five_count, tff_q5, ~tff_q4, ~tff_q3, ~tff_q2, tff_q1, tff_q0);\n")
f.write("and tff_thirty_six_count_and(thirty_six_count, tff_q5, ~tff_q4, ~tff_q3, tff_q2, ~tff_q1, ~tff_q0);\n")

f.write("assign div_resultRDY = thirty_five_count;\n\n")

f.write("// Check for exception by checking whether operandB = 0\n")
f.write("wire temp_div_exception;\n")
f.write("assign temp_div_exception = latched_data_B || {32{1'b0}} ? 1'b0 : 1'b1;\n\n")
f.write("dffe_ref dff(div_exception, temp_div_exception, clock, thirty_four_count, tff_reset);\n\n")

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

f.write("wire [31:0] M, negative_M;\n")
f.write("assign M = data_operandB_result;\n")
f.write("assign negative_M = latched_data_B[31] ? latched_data_B : negative_B;\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")


f.write("// Start of division algorithm\n")
f.write("wire [31:0] M_or_negativeM, remainder_out, remainder_in, result_out, result_in, ls_remainder_out, ls_result_out, alu_result;\n")
f.write("wire ctrl_ADD, cout_remainder;\nassign ctrl_ADD = remainder_out[31];\n")
f.write("register32 reg_remainder(remainder_out, remainder_in, ~zero_count, ctrl_DIV, clock);\n")
f.write("register32 reg_result(result_out, result_in, ~zero_count, ctrl_DIV, clock);\n")
f.write("left_shifter_64 ls_64(remainder_out, result_out, ls_remainder_out, ls_result_out);\n")
f.write("assign M_or_negativeM = ctrl_ADD ? M : negative_M;\n")
f.write("cla_32 result_cla(alu_result, cout_remainder, M_or_negativeM, ls_remainder_out, 1'b0);\n")
f.write("assign remainder_in = one_count ? {32{1'b0}} : alu_result;\n")
f.write("assign result_in[0] = one_count ? data_operandA_result[0] : (alu_result[31] ? 1'b0 : 1'b1);\n")
f.write("assign result_in[31:1] = one_count ? data_operandA_result[31:1] : ls_result_out[31:1];\n")
f.write("\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")


f.write("wire [31:0] negative_result;\nwire negative_result_cout;\n")
f.write("cla_32 negative_result_cla(negative_result, negative_result_cout, ~result_out, {32{1'b0}}, 1'b1);\n")
f.write("\nwire result_is_negative;\n")
f.write("xor result_is_negative_xor(result_is_negative, latched_data_A[31], latched_data_B[31]);\n")
f.write("wire [31:0] maybe_negative_div_result, temp_div_result;\n")
f.write("assign maybe_negative_div_result = result_is_negative ? negative_result : result_out;\n")
f.write("assign temp_div_result = temp_div_exception ? {32{1'b0}} : maybe_negative_div_result;\n")
f.write("register32 reg_data_result(div_result, temp_div_result, thirty_four_count, tff_reset, clock);\n")



f.write("endmodule")