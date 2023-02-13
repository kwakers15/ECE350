module register32(out, in, in_enable, clr, clk);
  input [31:0] in;
  input in_enable, clr, clk;
  output [31:0] out;

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin: loop1
      dffe_ref dff(out[i], in[i], clk, in_enable, clr);
    end
  endgenerate

endmodule