`timescale 1 ns / 100 ps
module eight_comparator_tb;
  wire [7:0] A, B;
  wire preEQ, preGT, EQ, GT;
  eight_comparator comp(preEQ, preGT, A, B, EQ, GT);
  integer i;
  integer j;
  integer k;
  assign A = i[7:0];
  assign B = j[7:0];
  assign {preEQ, preGT} = k[1:0];

  initial begin
    // for (i = 0; i < 4; i = i + 1) begin
    //   #20;
    //   $display("preEQ:%b, preGT:%b, A:%b, B:%b, EQ:%b, GT:%b", preEQ, preGT, A, B, EQ, GT, );
    // end
    assign i = 185;
    assign j = 185;
    for (k = 0; k < 4; k = k + 1) begin
      #20;
      $display("preEQ:%b, preGT:%b, A:%b, B:%b, EQ:%b, GT:%b", preEQ, preGT, A, B, EQ, GT, );
    end
    #20;
    assign i = 195;
    assign j = 163;
    for (k = 0; k < 4; k = k + 1) begin
      #20;
      $display("preEQ:%b, preGT:%b, A:%b, B:%b, EQ:%b, GT:%b", preEQ, preGT, A, B, EQ, GT, );
    end
    #20;
    assign i = 25;
    assign j = 85;
    for (k = 0; k < 4; k = k + 1) begin
      #20;
      $display("preEQ:%b, preGT:%b, A:%b, B:%b, EQ:%b, GT:%b", preEQ, preGT, A, B, EQ, GT, );
    end
    #20;
    $finish;
  end

  initial begin
    $dumpfile("eight_comparator.vcd");
    $dumpvars(0, eight_comparator_tb);
  end
endmodule