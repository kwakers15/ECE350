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

f.write("assign data_resultRDY = eighteen_count;\n\n")

f.write("// Check for exception by checking whether operandB = 0\n")
f.write("assign data_exception = data_operandB || {32{1'b0}} ? 1'b0 : 1'b1;\n")














f.write("endmodule")