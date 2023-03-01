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
    wire [31:0] mult_result, div_result;
    wire mult_resultRDY, div_resultRDY, mult_exception, div_exception;
    multiplier mult(mult_result, mult_resultRDY, mult_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);
    divider div(div_result, div_resultRDY, div_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);

    // SR latch
    wire sr_out, sr_out_bar;
    nor sr_nor1(sr_out, ctrl_DIV, sr_out_bar);
    nor sr_nor2(sr_out_bar, sr_out, ctrl_MULT);

    assign data_result = sr_out ? mult_result : div_result;
    assign data_exception = sr_out ? mult_exception : div_exception;
    or data_resultRDY_or(data_resultRDY, mult_resultRDY, div_resultRDY);
endmodule