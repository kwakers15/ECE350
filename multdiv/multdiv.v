module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    wire [31:0] msb_data_result;
    multiplier mult(data_result, msb_data_result, data_resultRDY, data_exception, data_operandA, data_operandB, clock);
endmodule