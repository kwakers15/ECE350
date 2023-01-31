`timescale 1 ns / 100 ps
module two_bit_comparator_tb;
  wire [1:0] A, B;
  wire preEQ, preGT, EQ, GT;
  two_bit_comparator comp(preEQ, preGT, A, B, EQ, GT);
  integer i;
  assign A = i[1:0];
  assign B = i[3:2];
  assign preEQ = i[5];
  assign preGT = i[4];

  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      #20;
      $display("preEQ:%b, preGT:%b, A:%b, B:%b, EQ:%b, GT:%b", preEQ, preGT, A, B, EQ, GT, );
    end
    $finish;
  end

  initial begin
    $dumpfile("2_bit_comparator.vcd");
    $dumpvars(0, two_bit_comparator_tb);
  end
endmodule