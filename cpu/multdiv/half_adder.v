module half_adder(S, Cout, A, B);
  input A, B;
  output S, Cout;

  and cout_and(Cout, A, B);
  xor sum_xor(S, A, B);
endmodule