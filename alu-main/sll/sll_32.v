module sll_32(data_result, data_operandA, ctrl_shiftamt);
  input [31:0] data_operandA;
  input [4:0] ctrl_shiftamt;
  output [31:0] data_result;
  wire [31:0] shift_1_result, shift_2_result, shift_4_result, shift_8_result;
  sll_1 shift_1(shift_1_result, data_operandA, ctrl_shiftamt[0]);
  sll_2 shift_2(shift_2_result, shift_1_result, ctrl_shiftamt[1]);
  sll_4 shift_4(shift_4_result, shift_2_result, ctrl_shiftamt[2]);
  sll_8 shift_8(shift_8_result, shift_4_result, ctrl_shiftamt[3]);
  sll_16 shift_16(data_result, shift_8_result, ctrl_shiftamt[4]);
endmodule