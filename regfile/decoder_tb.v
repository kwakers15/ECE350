`timescale 1 ns / 100 ps
module decoder_tb();
  wire [31:0] out;
  wire [4:0] select;
  decoder32 dec(out, select, 1'b1);
  integer i;
  assign select = i[4:0];
  initial begin   
    for (i = 0; i < 32; i = i + 1) begin
      #20;
      $display("out:%b, select:%b", out, select);
      #10;
    end
    $finish;
  end

  initial begin
    $dumpfile("decoder.vcd");
    $dumpvars(0, decoder_tb);
  end
endmodule