module tff(Q, T, clk, en, clr);
  input T, clk, en, clr;
  output Q;
  wire or_1, or_2;
  and q_and(or_1, Q, ~T);
  and q_bar_and(or_2, ~Q, T);
  wire dff_d;
  or dff_or(dff_d, or_1, or_2);
  dffe_ref dff(Q, dff_d, clk, en, clr);
endmodule