module two_bit_comparator(preEQ, preGT, A, B, EQ, GT);
  input preEQ, preGT;
  input [1:0] A, B;
  output EQ, GT;
  wire [2:0] select;
  assign select[2:1] = A;
  assign select[0] = B[1];
  wire notB0, GT_out, EQ_out;
  not not_B0(notB0, B[0]);
  mux_2 GT_select(GT, preEQ, preGT, GT_out);
  mux_8 GT_mux(GT_out, select, 0, 0, notB0, 0, 1, 0, 1, notB0);
  mux_2 EQ_select(EQ, preEQ, 0, EQ_out);
  mux_8 EQ_mux(EQ_out, select, notB0, 0, B[0], 0, 0, notB0, 0, B[0]);
endmodule