f = open("divider_verilog.txt", "w+")

# module declaration
f.write("module divider(data_result, data_resultRDY, data_exception, data_operandA, data_operandB, clock);\n")
f.write("input [31:0] data_operandA, data_operandB;\ninput clock;\noutput [31:0] data_result;\noutput data_resultRDY, data_exception;\n\n")


