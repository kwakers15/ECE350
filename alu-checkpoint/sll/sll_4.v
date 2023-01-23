module sll_4(data_result, data_operandA, ctrl_bit);
  input [31:0] data_operandA;
  input ctrl_bit;
  output [31:0] data_result;

  assign data_result[0] = ctrl_bit ? 0 : data_operandA[0];
  assign data_result[1] = ctrl_bit ? 0 : data_operandA[1];
  assign data_result[2] = ctrl_bit ? 0 : data_operandA[2];
  assign data_result[3] = ctrl_bit ? 0 : data_operandA[3];
  assign data_result[4] = ctrl_bit ? data_operandA[0] : data_operandA[4];
  assign data_result[5] = ctrl_bit ? data_operandA[1] : data_operandA[5];
  assign data_result[6] = ctrl_bit ? data_operandA[2] : data_operandA[6];
  assign data_result[7] = ctrl_bit ? data_operandA[3] : data_operandA[7];
  assign data_result[8] = ctrl_bit ? data_operandA[4] : data_operandA[8];
  assign data_result[9] = ctrl_bit ? data_operandA[5] : data_operandA[9];
  assign data_result[10] = ctrl_bit ? data_operandA[6] : data_operandA[10];
  assign data_result[11] = ctrl_bit ? data_operandA[7] : data_operandA[11];
  assign data_result[12] = ctrl_bit ? data_operandA[8] : data_operandA[12];
  assign data_result[13] = ctrl_bit ? data_operandA[9] : data_operandA[13];
  assign data_result[14] = ctrl_bit ? data_operandA[10] : data_operandA[14];
  assign data_result[15] = ctrl_bit ? data_operandA[11] : data_operandA[15];
  assign data_result[16] = ctrl_bit ? data_operandA[12] : data_operandA[16];
  assign data_result[17] = ctrl_bit ? data_operandA[13] : data_operandA[17];
  assign data_result[18] = ctrl_bit ? data_operandA[14] : data_operandA[18];
  assign data_result[19] = ctrl_bit ? data_operandA[15] : data_operandA[19];
  assign data_result[20] = ctrl_bit ? data_operandA[16] : data_operandA[20];
  assign data_result[21] = ctrl_bit ? data_operandA[17] : data_operandA[21];
  assign data_result[22] = ctrl_bit ? data_operandA[18] : data_operandA[22];
  assign data_result[23] = ctrl_bit ? data_operandA[19] : data_operandA[23];
  assign data_result[24] = ctrl_bit ? data_operandA[20] : data_operandA[24];
  assign data_result[25] = ctrl_bit ? data_operandA[21] : data_operandA[25];
  assign data_result[26] = ctrl_bit ? data_operandA[22] : data_operandA[26];
  assign data_result[27] = ctrl_bit ? data_operandA[23] : data_operandA[27];
  assign data_result[28] = ctrl_bit ? data_operandA[24] : data_operandA[28];
  assign data_result[29] = ctrl_bit ? data_operandA[25] : data_operandA[29];
  assign data_result[30] = ctrl_bit ? data_operandA[26] : data_operandA[30];
  assign data_result[31] = ctrl_bit ? data_operandA[27] : data_operandA[31];

endmodule