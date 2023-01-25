module cla_adder_32(data_result, isNotEqual, isLessThan, overflow, data_operandA, data_operandB, Cin);
  input [31:0] data_operandA, data_operandB;
  input Cin;
  output [31:0] data_result;
  output isNotEqual, isLessThan, overflow;
endmodule