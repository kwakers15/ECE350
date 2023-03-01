module decoder32(out, select, enable);
  input [4:0] select;
  input enable;
  output [31:0] out;

  wire [31:0] shift_input;
  assign shift_input[0] = enable;
  assign shift_input[31:1] = {31{1'b0}};
  sll_32 left_shift(out, shift_input, select);
endmodule