module thirty_two_comparator(preEQ, preGT, A, B, EQ, GT);
  input [31:0] A, B;
  input preEQ, preGT;
  output EQ, GT;

  wire EQ3, EQ2, EQ1, EQ0, GT3, GT2, GT1, GT0;

  eight_comparator comp3(preEQ, preGT, A[31:24], B[31:24], EQ3, GT3);
  eight_comparator comp2(EQ3, GT3, A[23:16], B[23:16], EQ2, GT2);
  eight_comparator comp1(EQ2, GT2, A[15:8], B[15:8], EQ1, GT1);
  eight_comparator comp0(EQ1, GT1, A[7:0], B[7:0], EQ, GT);
endmodule