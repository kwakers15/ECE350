`timescale 1 ns / 100 ps
module not_32_tb;
  wire [31:0] data_operandA;
  wire [31:0] out;
  not_32 not32(out, data_operandA);
  integer i;
  assign data_operandA = i[31:0];

  initial begin
    for (i = 0; i < 1000; i = i + 1) begin
      #20;
      $display("input:%b, output:%b", data_operandA, out);
    end
    $finish;
  end

  initial begin
    $dumpfile("not_32.vcd");
    $dumpvars(0, not_32_tb);
  end
endmodule