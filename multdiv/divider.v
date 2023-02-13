module divider(div_result, div_resultRDY, div_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);
  input [31:0] data_operandA, data_operandB;
  input ctrl_MULT, ctrl_DIV, clock;
  output [31:0] div_result;
  output div_resultRDY, div_exception;

endmodule