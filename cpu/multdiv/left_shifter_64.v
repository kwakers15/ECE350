module left_shifter_64(remainder_in, result_in, remainder_out, result_out);
  input [31:0] remainder_in, result_in;
  output [31:0] remainder_out, result_out;

  wire [63:0] temp1, temp2;
  assign temp1[63:32] = remainder_in;
  assign temp1[31:0] = result_in;

  assign temp2 = temp1 << 1'b1;

  assign remainder_out = temp2[63:32];
  assign result_out = temp2[31:0];
endmodule