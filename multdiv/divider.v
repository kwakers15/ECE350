module divider(div_result, div_resultRDY, div_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);
input [31:0] data_operandA, data_operandB;
input ctrl_MULT, ctrl_DIV, clock;
output [31:0] div_result;
output div_resultRDY, div_exception;

// latch data operands when clk AND ctrl_DIV
wire [31:0] latched_data_A, latched_data_B;
register32 regA(latched_data_A, data_operandA, ctrl_DIV, 1'b0, clock);
register32 regB(latched_data_B, data_operandB, ctrl_DIV, 1'b0, clock);

// Wires for SR Latch and TFF counter
wire sr_out, sr_out_bar, sr_reset, tff_q0, tff_q1, tff_q2, tff_q3, tff_q4, tff_t2, tff_t3, tff_t4, seventeen_count, eighteen_count, nineteen_count, tff_reset;

// SR latch for counter
and sr_seventeen_count_and(seventeen_count, tff_q4, ~tff_q3, ~tff_q2, ~tff_q1, tff_q0);
and sr_eighteen_count_and(eighteen_count, tff_q4, ~tff_q3, ~tff_q2, tff_q1, ~tff_q0);
and sr_nineteen_count_and(nineteen_count, tff_q4, ~tff_q3, ~tff_q2, tff_q1, tff_q0);
or sr_reset_or(sr_reset, nineteen_count, ctrl_MULT);
nor sr_nor1(sr_out, sr_out_bar, sr_reset);
nor sr_not2(sr_out_bar, ctrl_DIV, sr_out);

// T flip flop counter
or tff_reset_or(tff_reset, nineteen_count, ctrl_MULT, ctrl_DIV);
tff tff_0(tff_q0, 1'b1, clock, sr_out, tff_reset);
tff tff_1(tff_q1, tff_q0, clock, sr_out, tff_reset);
and tff_t2_and(tff_t2, tff_q1, tff_q0);
tff tff_2(tff_q2, tff_t2, clock, sr_out, tff_reset);
and tff_t3_and(tff_t3, tff_q0, tff_q1, tff_q2);
tff tff_3(tff_q3, tff_t3, clock, sr_out, tff_reset);
and tff_t4_and(tff_t4, tff_q0, tff_q1, tff_q2, tff_q3);
tff tff_4(tff_q4, tff_t4, clock, sr_out, tff_reset);
assign div_resultRDY = eighteen_count;

// Check for exception by checking whether operandB = 0
wire temp_div_exception;
assign temp_div_exception = latched_data_B || {32{1'b0}} ? 1'b0 : 1'b1;

dffe_ref dff(div_exception, temp_div_exception, clock, seventeen_count, tff_reset);

// flip the sign of A and B if negative
wire [31:0] negative_A, negative_B;
wire [31:0] data_operandA_result, data_operandB_result;
wire a_cout, b_cout;
cla_32 a_result(negative_A, a_cout, ~latched_data_A, {32{1'b0}}, 1'b1);
cla_32 b_result(negative_B, b_cout, ~latched_data_B, {32{1'b0}}, 1'b1);
assign data_operandA_result = latched_data_A[31] ? negative_A : latched_data_A;
assign data_operandB_result = latched_data_B[31] ? negative_B : latched_data_B;

// ------------------------------------------------------------

wire [63:0] left_shifted_AQ_0;
assign left_shifted_AQ_0[31:0] = data_operandA_result;
assign left_shifted_AQ_0[63:32] = {32{1'b0}};

wire [31:0] M, negative_M;
assign M = data_operandB_result;
assign negative_M = latched_data_B[31] ? latched_data_B : negative_B;

// ------------------------------------------------------------

// Start of division algorithm
wire add_M;
assign add_M = 1'b0;
wire [63:0] left_shifted_AQ_1;
assign left_shifted_AQ_1 = left_shifted_AQ_0 << 1'b1;
wire [31:0] M_1;
assign M_1 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_1_MSB;
wire cout_1;
cla_32 trial_1(AQ_1_MSB, cout_1, left_shifted_AQ_1[63:32], M_1, 1'b0);
assign add_M = AQ_1_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_1[63:32] = AQ_1_MSB;
assign left_shifted_AQ_1[0] = AQ_1_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_2;
assign left_shifted_AQ_2 = left_shifted_AQ_1 << 1'b1;
wire [31:0] M_2;
assign M_2 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_2_MSB;
wire cout_2;
cla_32 trial_2(AQ_2_MSB, cout_2, left_shifted_AQ_2[63:32], M_2, 1'b0);
assign add_M = AQ_2_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_2[63:32] = AQ_2_MSB;
assign left_shifted_AQ_2[0] = AQ_2_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_3;
assign left_shifted_AQ_3 = left_shifted_AQ_2 << 1'b1;
wire [31:0] M_3;
assign M_3 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_3_MSB;
wire cout_3;
cla_32 trial_3(AQ_3_MSB, cout_3, left_shifted_AQ_3[63:32], M_3, 1'b0);
assign add_M = AQ_3_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_3[63:32] = AQ_3_MSB;
assign left_shifted_AQ_3[0] = AQ_3_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_4;
assign left_shifted_AQ_4 = left_shifted_AQ_3 << 1'b1;
wire [31:0] M_4;
assign M_4 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_4_MSB;
wire cout_4;
cla_32 trial_4(AQ_4_MSB, cout_4, left_shifted_AQ_4[63:32], M_4, 1'b0);
assign add_M = AQ_4_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_4[63:32] = AQ_4_MSB;
assign left_shifted_AQ_4[0] = AQ_4_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_5;
assign left_shifted_AQ_5 = left_shifted_AQ_4 << 1'b1;
wire [31:0] M_5;
assign M_5 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_5_MSB;
wire cout_5;
cla_32 trial_5(AQ_5_MSB, cout_5, left_shifted_AQ_5[63:32], M_5, 1'b0);
assign add_M = AQ_5_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_5[63:32] = AQ_5_MSB;
assign left_shifted_AQ_5[0] = AQ_5_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_6;
assign left_shifted_AQ_6 = left_shifted_AQ_5 << 1'b1;
wire [31:0] M_6;
assign M_6 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_6_MSB;
wire cout_6;
cla_32 trial_6(AQ_6_MSB, cout_6, left_shifted_AQ_6[63:32], M_6, 1'b0);
assign add_M = AQ_6_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_6[63:32] = AQ_6_MSB;
assign left_shifted_AQ_6[0] = AQ_6_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_7;
assign left_shifted_AQ_7 = left_shifted_AQ_6 << 1'b1;
wire [31:0] M_7;
assign M_7 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_7_MSB;
wire cout_7;
cla_32 trial_7(AQ_7_MSB, cout_7, left_shifted_AQ_7[63:32], M_7, 1'b0);
assign add_M = AQ_7_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_7[63:32] = AQ_7_MSB;
assign left_shifted_AQ_7[0] = AQ_7_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_8;
assign left_shifted_AQ_8 = left_shifted_AQ_7 << 1'b1;
wire [31:0] M_8;
assign M_8 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_8_MSB;
wire cout_8;
cla_32 trial_8(AQ_8_MSB, cout_8, left_shifted_AQ_8[63:32], M_8, 1'b0);
assign add_M = AQ_8_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_8[63:32] = AQ_8_MSB;
assign left_shifted_AQ_8[0] = AQ_8_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_9;
assign left_shifted_AQ_9 = left_shifted_AQ_8 << 1'b1;
wire [31:0] M_9;
assign M_9 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_9_MSB;
wire cout_9;
cla_32 trial_9(AQ_9_MSB, cout_9, left_shifted_AQ_9[63:32], M_9, 1'b0);
assign add_M = AQ_9_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_9[63:32] = AQ_9_MSB;
assign left_shifted_AQ_9[0] = AQ_9_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_10;
assign left_shifted_AQ_10 = left_shifted_AQ_9 << 1'b1;
wire [31:0] M_10;
assign M_10 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_10_MSB;
wire cout_10;
cla_32 trial_10(AQ_10_MSB, cout_10, left_shifted_AQ_10[63:32], M_10, 1'b0);
assign add_M = AQ_10_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_10[63:32] = AQ_10_MSB;
assign left_shifted_AQ_10[0] = AQ_10_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_11;
assign left_shifted_AQ_11 = left_shifted_AQ_10 << 1'b1;
wire [31:0] M_11;
assign M_11 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_11_MSB;
wire cout_11;
cla_32 trial_11(AQ_11_MSB, cout_11, left_shifted_AQ_11[63:32], M_11, 1'b0);
assign add_M = AQ_11_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_11[63:32] = AQ_11_MSB;
assign left_shifted_AQ_11[0] = AQ_11_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_12;
assign left_shifted_AQ_12 = left_shifted_AQ_11 << 1'b1;
wire [31:0] M_12;
assign M_12 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_12_MSB;
wire cout_12;
cla_32 trial_12(AQ_12_MSB, cout_12, left_shifted_AQ_12[63:32], M_12, 1'b0);
assign add_M = AQ_12_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_12[63:32] = AQ_12_MSB;
assign left_shifted_AQ_12[0] = AQ_12_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_13;
assign left_shifted_AQ_13 = left_shifted_AQ_12 << 1'b1;
wire [31:0] M_13;
assign M_13 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_13_MSB;
wire cout_13;
cla_32 trial_13(AQ_13_MSB, cout_13, left_shifted_AQ_13[63:32], M_13, 1'b0);
assign add_M = AQ_13_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_13[63:32] = AQ_13_MSB;
assign left_shifted_AQ_13[0] = AQ_13_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_14;
assign left_shifted_AQ_14 = left_shifted_AQ_13 << 1'b1;
wire [31:0] M_14;
assign M_14 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_14_MSB;
wire cout_14;
cla_32 trial_14(AQ_14_MSB, cout_14, left_shifted_AQ_14[63:32], M_14, 1'b0);
assign add_M = AQ_14_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_14[63:32] = AQ_14_MSB;
assign left_shifted_AQ_14[0] = AQ_14_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_15;
assign left_shifted_AQ_15 = left_shifted_AQ_14 << 1'b1;
wire [31:0] M_15;
assign M_15 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_15_MSB;
wire cout_15;
cla_32 trial_15(AQ_15_MSB, cout_15, left_shifted_AQ_15[63:32], M_15, 1'b0);
assign add_M = AQ_15_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_15[63:32] = AQ_15_MSB;
assign left_shifted_AQ_15[0] = AQ_15_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_16;
assign left_shifted_AQ_16 = left_shifted_AQ_15 << 1'b1;
wire [31:0] M_16;
assign M_16 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_16_MSB;
wire cout_16;
cla_32 trial_16(AQ_16_MSB, cout_16, left_shifted_AQ_16[63:32], M_16, 1'b0);
assign add_M = AQ_16_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_16[63:32] = AQ_16_MSB;
assign left_shifted_AQ_16[0] = AQ_16_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_17;
assign left_shifted_AQ_17 = left_shifted_AQ_16 << 1'b1;
wire [31:0] M_17;
assign M_17 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_17_MSB;
wire cout_17;
cla_32 trial_17(AQ_17_MSB, cout_17, left_shifted_AQ_17[63:32], M_17, 1'b0);
assign add_M = AQ_17_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_17[63:32] = AQ_17_MSB;
assign left_shifted_AQ_17[0] = AQ_17_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_18;
assign left_shifted_AQ_18 = left_shifted_AQ_17 << 1'b1;
wire [31:0] M_18;
assign M_18 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_18_MSB;
wire cout_18;
cla_32 trial_18(AQ_18_MSB, cout_18, left_shifted_AQ_18[63:32], M_18, 1'b0);
assign add_M = AQ_18_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_18[63:32] = AQ_18_MSB;
assign left_shifted_AQ_18[0] = AQ_18_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_19;
assign left_shifted_AQ_19 = left_shifted_AQ_18 << 1'b1;
wire [31:0] M_19;
assign M_19 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_19_MSB;
wire cout_19;
cla_32 trial_19(AQ_19_MSB, cout_19, left_shifted_AQ_19[63:32], M_19, 1'b0);
assign add_M = AQ_19_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_19[63:32] = AQ_19_MSB;
assign left_shifted_AQ_19[0] = AQ_19_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_20;
assign left_shifted_AQ_20 = left_shifted_AQ_19 << 1'b1;
wire [31:0] M_20;
assign M_20 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_20_MSB;
wire cout_20;
cla_32 trial_20(AQ_20_MSB, cout_20, left_shifted_AQ_20[63:32], M_20, 1'b0);
assign add_M = AQ_20_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_20[63:32] = AQ_20_MSB;
assign left_shifted_AQ_20[0] = AQ_20_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_21;
assign left_shifted_AQ_21 = left_shifted_AQ_20 << 1'b1;
wire [31:0] M_21;
assign M_21 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_21_MSB;
wire cout_21;
cla_32 trial_21(AQ_21_MSB, cout_21, left_shifted_AQ_21[63:32], M_21, 1'b0);
assign add_M = AQ_21_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_21[63:32] = AQ_21_MSB;
assign left_shifted_AQ_21[0] = AQ_21_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_22;
assign left_shifted_AQ_22 = left_shifted_AQ_21 << 1'b1;
wire [31:0] M_22;
assign M_22 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_22_MSB;
wire cout_22;
cla_32 trial_22(AQ_22_MSB, cout_22, left_shifted_AQ_22[63:32], M_22, 1'b0);
assign add_M = AQ_22_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_22[63:32] = AQ_22_MSB;
assign left_shifted_AQ_22[0] = AQ_22_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_23;
assign left_shifted_AQ_23 = left_shifted_AQ_22 << 1'b1;
wire [31:0] M_23;
assign M_23 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_23_MSB;
wire cout_23;
cla_32 trial_23(AQ_23_MSB, cout_23, left_shifted_AQ_23[63:32], M_23, 1'b0);
assign add_M = AQ_23_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_23[63:32] = AQ_23_MSB;
assign left_shifted_AQ_23[0] = AQ_23_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_24;
assign left_shifted_AQ_24 = left_shifted_AQ_23 << 1'b1;
wire [31:0] M_24;
assign M_24 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_24_MSB;
wire cout_24;
cla_32 trial_24(AQ_24_MSB, cout_24, left_shifted_AQ_24[63:32], M_24, 1'b0);
assign add_M = AQ_24_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_24[63:32] = AQ_24_MSB;
assign left_shifted_AQ_24[0] = AQ_24_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_25;
assign left_shifted_AQ_25 = left_shifted_AQ_24 << 1'b1;
wire [31:0] M_25;
assign M_25 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_25_MSB;
wire cout_25;
cla_32 trial_25(AQ_25_MSB, cout_25, left_shifted_AQ_25[63:32], M_25, 1'b0);
assign add_M = AQ_25_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_25[63:32] = AQ_25_MSB;
assign left_shifted_AQ_25[0] = AQ_25_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_26;
assign left_shifted_AQ_26 = left_shifted_AQ_25 << 1'b1;
wire [31:0] M_26;
assign M_26 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_26_MSB;
wire cout_26;
cla_32 trial_26(AQ_26_MSB, cout_26, left_shifted_AQ_26[63:32], M_26, 1'b0);
assign add_M = AQ_26_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_26[63:32] = AQ_26_MSB;
assign left_shifted_AQ_26[0] = AQ_26_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_27;
assign left_shifted_AQ_27 = left_shifted_AQ_26 << 1'b1;
wire [31:0] M_27;
assign M_27 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_27_MSB;
wire cout_27;
cla_32 trial_27(AQ_27_MSB, cout_27, left_shifted_AQ_27[63:32], M_27, 1'b0);
assign add_M = AQ_27_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_27[63:32] = AQ_27_MSB;
assign left_shifted_AQ_27[0] = AQ_27_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_28;
assign left_shifted_AQ_28 = left_shifted_AQ_27 << 1'b1;
wire [31:0] M_28;
assign M_28 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_28_MSB;
wire cout_28;
cla_32 trial_28(AQ_28_MSB, cout_28, left_shifted_AQ_28[63:32], M_28, 1'b0);
assign add_M = AQ_28_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_28[63:32] = AQ_28_MSB;
assign left_shifted_AQ_28[0] = AQ_28_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_29;
assign left_shifted_AQ_29 = left_shifted_AQ_28 << 1'b1;
wire [31:0] M_29;
assign M_29 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_29_MSB;
wire cout_29;
cla_32 trial_29(AQ_29_MSB, cout_29, left_shifted_AQ_29[63:32], M_29, 1'b0);
assign add_M = AQ_29_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_29[63:32] = AQ_29_MSB;
assign left_shifted_AQ_29[0] = AQ_29_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_30;
assign left_shifted_AQ_30 = left_shifted_AQ_29 << 1'b1;
wire [31:0] M_30;
assign M_30 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_30_MSB;
wire cout_30;
cla_32 trial_30(AQ_30_MSB, cout_30, left_shifted_AQ_30[63:32], M_30, 1'b0);
assign add_M = AQ_30_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_30[63:32] = AQ_30_MSB;
assign left_shifted_AQ_30[0] = AQ_30_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_31;
assign left_shifted_AQ_31 = left_shifted_AQ_30 << 1'b1;
wire [31:0] M_31;
assign M_31 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_31_MSB;
wire cout_31;
cla_32 trial_31(AQ_31_MSB, cout_31, left_shifted_AQ_31[63:32], M_31, 1'b0);
assign add_M = AQ_31_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_31[63:32] = AQ_31_MSB;
assign left_shifted_AQ_31[0] = AQ_31_MSB[31] ? 1'b0 : 1'b1;
wire [63:0] left_shifted_AQ_32;
assign left_shifted_AQ_32 = left_shifted_AQ_31 << 1'b1;
wire [31:0] M_32;
assign M_32 = add_M ? M : negative_M;
// Previous restoration + trial / Trial subtraction
wire [31:0] AQ_32_MSB;
wire cout_32;
cla_32 trial_32(AQ_32_MSB, cout_32, left_shifted_AQ_32[63:32], M_32, 1'b0);
assign add_M = AQ_32_MSB[31] ? 1'b1 : 1'b0;
assign left_shifted_AQ_32[63:32] = AQ_32_MSB;
assign left_shifted_AQ_32[0] = AQ_32_MSB[31] ? 1'b0 : 1'b1;

// ------------------------------------------------------------

wire [31:0] negative_result;
wire negative_result_cout;
cla_32 negative_result_cla(negative_result, negative_result_cout, ~left_shifted_AQ_32[31:0], {32{1'b0}}, 1'b1);

wire result_is_negative;
xor result_is_negative_xor(result_is_negative, latched_data_A[31], latched_data_B[31]);
wire [31:0] maybe_negative_div_result, temp_div_result;
assign maybe_negative_div_result = result_is_negative ? negative_result : left_shifted_AQ_32[31:0];
assign temp_div_result = div_exception ? {32{1'b0}} : maybe_negative_div_result;
register32 reg_data_result(div_result, temp_div_result, seventeen_count, tff_reset, clock);
endmodule