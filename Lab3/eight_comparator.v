module eight_comparator(preEQ, preGT, A, B, EQ, GT);
  input [7:0] A, B;
  input preEQ, preGT;
  output EQ, GT;

  wire EQ3, EQ2, EQ1, EQ0, GT3, GT2, GT1, GT0;

  two_bit_comparator comp3(preEQ, preGT, A[7:6], B[7:6], EQ3, GT3);
  two_bit_comparator comp2(EQ3, GT3, A[5:4], B[5:4], EQ2, GT2);
  two_bit_comparator comp1(EQ2, GT2, A[3:2], B[3:2], EQ1, GT1);
  two_bit_comparator comp0(EQ1, GT1, A[1:0], B[1:0], EQ, GT);
endmodule