module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // add your code here:
    wire [31:0] add_result, sub_result, and_result, or_result, sll_result, sra_result, w7, w8, input_B, not_operandB;
    wire Cin;

    not_32 not_B(not_operandB, data_operandB);
    mux_2 input_B_select(input_B, ctrl_ALUopcode[0], data_operandB, not_operandB);
    mux_2 alu_Cin(Cin, ctrl_ALUopcode[0], 0, 1);
    cla_32 adder(add_sub_result, isNotEqual, isLessThan, overflow, data_operandA, input_B, Cin);
    and_32 and_op(and_result, data_operandA, data_operandB);
    or_32 or_op(or_result, data_operandA, data_operandB);
    sll_32 sll_op(sll_result, data_operandA, ctrl_shiftamt);
    sra_32 sra_op(sra_result, data_operandA, ctrl_shiftamt);
    mux_8 choose_op(data_result, ctrl_ALUopcode[2:0], add_sub_result, add_sub_result, and_result, or_result, sll_result, sra_result, w7, w8);
endmodule