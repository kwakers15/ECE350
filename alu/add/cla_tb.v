`timescale 1 ns / 100 ps
module cla_tb;
  wire [31:0] data_operandA, data_operandB;
  reg Cin;
  wire isNotEqual, isLessThan, overflow;
  wire [31:0] data_result;
  cla_32 adder(data_result, isNotEqual, isLessThan, overflow, data_operandA, data_operandB, Cin);
  integer i;
  assign data_operandA = i[31:0];
  assign data_operandB = i[31:0];
  initial begin   
    Cin = 0;
    for (i = 0; i < 65536; i = i + 1) begin
      #20;
      $display("inputA:%b, inputB:%b, Cin:%b, output:%b", data_operandA, data_operandB, Cin, data_result);
      #10;
      Cin = ~Cin;
    end
    $finish;
  end

  initial begin
    $dumpfile("cla_32.vcd");
    $dumpvars(0, cla_tb);
  end
endmodule