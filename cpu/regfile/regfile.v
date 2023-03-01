module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// add your code here
	wire [31:0] rs1_out, rs2_out;
	decoder32 rs1(rs1_out, ctrl_readRegA, 1'b1);
	decoder32 rs2(rs2_out, ctrl_readRegB, 1'b1);

	wire [31:0] zero_data;
	register32 reg0(zero_data, data_writeReg, 1'b0, 1'b1, clock);
	tri_state_buffer32 reg0_rs1_buffer(data_readRegA, {32{1'b0}}, rs1_out[0]);
	tri_state_buffer32 reg0_rs2_buffer(data_readRegB, {32{1'b0}}, rs2_out[0]);

	wire [31:0] writeRegOut;
	decoder32 writeReg(writeRegOut, ctrl_writeReg, ctrl_writeEnable);

	genvar i;
	generate
		for (i = 1; i < 32; i = i + 1) begin: loop1
			wire [31:0] data;
			register32 reg32(data, data_writeReg, writeRegOut[i], ctrl_reset, clock);
			tri_state_buffer32 rs1_buffer(data_readRegA, data, rs1_out[i]);
			tri_state_buffer32 rs2_buffer(data_readRegB, data, rs2_out[i]);
		end
	endgenerate


endmodule