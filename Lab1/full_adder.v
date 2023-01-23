module full_adder(S, Cout, A, B, Cin);
  input A, B, Cin;
  output S, Cout;
  wire w1, w2, w3;
  xor sResult(S, A, B, Cin);
  and and1(w1, A, B);
  and and2(w2, A, Cin);
  and and3(w3, B, Cin);
  or or1(Cout, w1, w2, w3);
endmodule