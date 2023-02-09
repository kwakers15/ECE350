`timescale 1 ns / 100 ps
module mult_tb();
  wire [31:0] data_operandA, data_operandB;
  wire [31:0] data_result;
  wire [31:0] msb_data_result;
  wire clock, dataRDY, data_exception;
  multiplier mult(data_result, msb_data_result, dataRDY, data_exception, data_operandA, data_operandB, clock);
  integer i = -2048;
  integer j = 4096;
  assign data_operandA = i[31:0];
  assign data_operandB = j[31:0];
  initial begin   
    // for (i = 0; i < 500; i = i + 1) begin
      $display("inputA:%b, inputB:%b, output:%b, msbOut:%b, exception:%b", data_operandA, data_operandB, data_result, msb_data_result, data_exception);
      // #500;
    // end
    $finish;
  end

  initial begin
    $dumpfile("mult.vcd");
    $dumpvars(0, mult_tb);
  end
endmodule