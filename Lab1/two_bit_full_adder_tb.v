`timescale 1 ns / 100 ps
module two_bit_full_adder_tb;
  wire [1:0] A, B;
  wire Cin;
  wire [1:0] S;
  wire Cout;
  two_bit_full_adder adder(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
  integer i;
  assign {Cin, A, B} = i[4:0];
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      #20;
      $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);
    end
    $finish;
  end

  initial begin
    $dumpfile("Wave_2.vcd");
    $dumpvars(0, two_bit_full_adder_tb);
  end
endmodule