module two_bit_full_adder(S, Cout, A, B, Cin);
  input [1:0] A, B;
  input Cin;
  output [1:0] S;
  output Cout;
  wire w1;
  full_adder adder_1(S[0], w1, A[0], B[0], Cin);
  full_adder adder_2(S[1], Cout, A[1], B[1], w1);
endmodule