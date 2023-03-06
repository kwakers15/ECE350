module comp_mux_8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
  input [2:0] select;
  input in0, in1, in2, in3, in4, in5, in6, in7;
  output out;
  wire w1, w2;
  comp_mux_4 mux1(w1, select[1:0], in0, in1, in2, in3);
  comp_mux_4 mux2(w2, select[1:0], in4, in5, in6, in7);
  comp_mux_2 mux3(out, select[2], w1, w2);
endmodule