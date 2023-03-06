module two_bit_comparator(preEQ, preGT, A, B, EQ, GT);
  input preEQ, preGT;
  input [1:0] A, B;
  output EQ, GT;
  wire [2:0] select;
  assign select[2:1] = A;
  assign select[0] = B[1];
  wire notB0, GT_out, EQ_out;
  not not_B0(notB0, B[0]);
  comp_mux_2 GT_select(GT, preEQ, preGT, GT_out);
  comp_mux_8 GT_mux(GT_out, select, 1'b0, 1'b0, notB0, 1'b0, 1'b1, 1'b0, 1'b1, notB0);
  comp_mux_2 EQ_select(EQ, preEQ, 1'b0, EQ_out);
  comp_mux_8 EQ_mux(EQ_out, select, notB0, 1'b0, B[0], 1'b0, 1'b0, notB0, 1'b0, B[0]);
endmodule