module one_bit_adder(S, Cout, A, B, Cin);
  input A, B, Cin;
  output S, Cout;
  wire w0, w1, w2, w3, w4, w5, w6
  nand n0(w0, A, B);
  nand n1(w1, A, w0);
  nand n2(w2, w0, B);
  nand n3(w3, w1, w2);
  nand n4(w4, w3, Cin);
  nand n5(w5, w3, w4);
  nand n6(w6, w4, Cin);
  nand n7(Cout, w4, w0);
  nand n8(S, w5, w6);
endmodule