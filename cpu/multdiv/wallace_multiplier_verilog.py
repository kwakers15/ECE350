f = open("wallace_multiplier_verilog.txt", "w+")

# module declaration
f.write("module multiplier(data_result, data_resultRDY, data_exception, data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock);\n")
f.write("input [31:0] data_operandA, data_operandB;\ninput clock, ctrl_MULT, ctrl_DIV;\noutput [31:0] data_result;\noutput data_resultRDY, data_exception;\n\n")

f.write("// latch data operands when clk AND ctrl_MULT\n")
f.write("wire [31:0] latched_data_A, latched_data_B;\n")
f.write("register32 regA(latched_data_A, data_operandA, ctrl_MULT, 1'b0, clock);\n")
f.write("register32 regB(latched_data_B, data_operandB, ctrl_MULT, 1'b0, clock);\n\n")


f.write("// Wires for SR Latch and TFF counter\n")
f.write("wire sr_out, sr_out_bar, sr_reset, tff_q0, tff_q1, tff_q2, tff_t2, three_count, four_count, five_count, tff_reset;\n\n")

f.write("// SR latch for counter\n")
f.write("and sr_three_count_and(three_count, ~tff_q2, tff_q1, tff_q0);\n")
f.write("and sr_four_count_and(four_count, tff_q2, ~tff_q1, ~tff_q0);\n")
f.write("and sr_five_count_and(five_count, tff_q2, ~tff_q1, tff_q0);\n")
f.write("or sr_reset_or(sr_reset, five_count, ctrl_DIV);\n")
f.write("nor sr_nor1(sr_out, sr_out_bar, sr_reset);\n")
f.write("nor sr_not2(sr_out_bar, ctrl_MULT, sr_out);\n\n")

f.write("// T flip flop counter\n")
f.write("or tff_reset_or(tff_reset, five_count, ctrl_MULT, ctrl_DIV);\n")
f.write("tff tff_0(tff_q0, 1'b1, clock, sr_out, tff_reset);\n")
f.write("tff tff_1(tff_q1, tff_q0, clock, sr_out, tff_reset);\n")
f.write("and tff_t2_and(tff_t2, tff_q1, tff_q0);\n")
f.write("tff tff_2(tff_q2, tff_t2, clock, sr_out, tff_reset);\n\n")

f.write("assign data_resultRDY = four_count;\n\n")

f.write("// flip the sign if negative\n")

f.write("wire [31:0] maybe_flipped_A, maybe_flipped_B;\n")

f.write("assign maybe_flipped_A = latched_data_A[31] ? ~latched_data_A : latched_data_A;\n")

f.write("assign maybe_flipped_B = latched_data_B[31] ? ~latched_data_B : latched_data_B;\n")

f.write("wire [31:0] data_operandA_result, data_operandB_result;\n")

f.write("wire a_cout, b_cout;\n")

f.write("cla_32 a_result(data_operandA_result, a_cout, maybe_flipped_A, {32{1\'b0}}, latched_data_A[31]);\n")

f.write("cla_32 b_result(data_operandB_result, b_cout, maybe_flipped_B, {32{1\'b0}}, latched_data_B[31]);\n")

f.write("wire ")
for i in range(31):
	f.write("A"+str(i)+", ")
f.write("A31;\n\n")

for i in range(32):
	f.write("assign A"+str(i)+" = data_operandA_result["+str(i)+"];\n")

f.write("\nwire ")
for i in range(31):
	f.write("B"+str(i)+", ")
f.write("B31;\n\n")

for i in range(32):
	f.write("assign B"+str(i)+" = data_operandB_result["+str(i)+"];\n")

ptr = 0

wires = {}

while ptr != 32:
	f.write("\nwire ")
	aIndex = ptr
	bIndex = 0

	wireList = []
	aList = []
	bList = []

	# wire names
	while aIndex >= 0:
		wireName = "A"+str(aIndex)+"B"+str(bIndex)
		aName = "A"+str(aIndex)
		bName = "B"+str(bIndex)
		wireList.append(wireName)
		aList.append(aName)
		bList.append(bName)
		if aIndex == 0:
			f.write(wireName+";\n\n")
		else:
			f.write(wireName+", ")
		aIndex -= 1
		bIndex += 1

	# and gates to form partial products
	index = 0
	for wire in wireList:
		f.write("and "+wire+"_and"+"("+wire+", "+aList[index]+", "+bList[index]+");\n")
		index += 1

	# separators
	f.write("\n// bit position "+str(ptr))
	for i in range(50):
		f.write("-")
	f.write("\n\n")

	wires[ptr] = wireList
	ptr += 1

while ptr != 63:
	f.write("wire ")
	aIndex = 31
	bIndex = ptr - 31

	wireList = []
	aList = []
	bList = []

	# wire names
	while bIndex <= 31:
		wireName = "A"+str(aIndex)+"B"+str(bIndex)
		aName = "A"+str(aIndex)
		bName = "B"+str(bIndex)
		wireList.append(wireName)
		aList.append(aName)
		bList.append(bName)
		if bIndex == 31:
			f.write(wireName+";\n\n")
		else:
			f.write(wireName+", ")
		aIndex -= 1
		bIndex += 1

	# and gates to form partial products
	index = 0
	for wire in wireList:
		f.write("and "+wire+"_and"+"("+wire+", "+aList[index]+", "+bList[index]+");\n")
		index += 1

	# separators
	f.write("\n// bit position "+str(ptr))
	for i in range(60):
		f.write("-")
	f.write("\n\n")

	wires[ptr] = wireList
	ptr += 1

wires[63] = []

outer_wire_index = 0

operandA = []
operandB = []

done_with_adding = False

num = 0
while (not done_with_adding):

	# when equal to 32, we know to move on to use the cla adder to sum the two 64 bit numbers
	num_satisfied_bits = 0

	# when < 0, it is the first bit position with more than two bits
	first_three = -1

	operandA = []
	operandB = []

	num_full_adders = 0
	num_half_adders = 0

	combine = 0

	for bitNum, wire_list in wires.items():
		num_wires = len(wire_list)
		if num_wires < 3 and combine == 0:
			operandA.append(wire_list[0])
			if (num_wires == 1):
				operandB.append("1'b0")
			else:
				operandB.append(wire_list[1])
			num_satisfied_bits += 1
			if num_satisfied_bits == 64:
				done_with_adding = True
			continue

		num_wires -= (num_half_adders + num_full_adders)
		combine = 1
		if first_three < 0:
			# use half adder
			first_three = 1
			sum_bit = "sum_"+str(bitNum)+"_0_"+str(outer_wire_index)
			cout_bit = "cout_"+str(bitNum)+"_0_"+str(outer_wire_index)
			f.write("wire "+sum_bit+", "+cout_bit+";\n\n")
			f.write("half_adder ha_"+str(bitNum)+"_0_"+str(outer_wire_index)+"("+sum_bit+", "+cout_bit+", "+wire_list[0]+", "+wire_list[1]+");\n\n")
			del wires[bitNum][0:2]
			wires[bitNum].append(sum_bit)
			wires[bitNum+1].append(cout_bit)
			num_half_adders = 1
			
		else:
			if bitNum > 60 and num == 0:
				num_half_adders = 0
				num_full_adders = 0
				continue
			if bitNum >= 60 and num == 1:
				num_half_adders = 0
				num_full_adders = 0
				continue
			if bitNum > 57 and num == 3:
				num_half_adders = 0
				num_full_adders = 0
				continue
			if bitNum > 58 and num == 4:
				num_half_adders = 0
				num_full_adders = 0
				continue
			if bitNum > 59 and num == 5:
				num_half_adders = 0
				num_full_adders = 0
				continue
			if bitNum > 60 and num == 6:
				num_half_adders = 0
				num_full_adders = 0
				continue	
			if bitNum > 61 and num == 7:
				num_half_adders = 0
				num_full_adders = 0
				continue	
			wire_num = 0
			# use full adder
			num_full_adders = (int) (num_wires / 3)
			num_half_adders = 0
			if num_wires % 3 == 2:
				num_half_adders = 1
			for i in range(num_full_adders):	
				sum_bit = "sum_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)
				cout_bit = "cout_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)
				f.write("wire "+sum_bit+", "+cout_bit+";\n\n")
				f.write("full_adder fa_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)+"("+sum_bit+", "+cout_bit+", "+wire_list[0]+", "+wire_list[1]+", "+wire_list[2]+");\n\n")
				del wires[bitNum][0:3]
				wires[bitNum].append(sum_bit)
				wires[bitNum+1].append(cout_bit)
				wire_num += 1
			for i in range(num_half_adders):
				sum_bit = "sum_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)
				cout_bit = "cout_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)
				f.write("wire "+sum_bit+", "+cout_bit+";\n\n")
				f.write("half_adder ha_"+str(bitNum)+"_"+str(wire_num)+"_"+str(outer_wire_index)+"("+sum_bit+", "+cout_bit+", "+wire_list[0]+", "+wire_list[1]+");\n\n")
				del wires[bitNum][0:2]
				wires[bitNum].append(sum_bit)
				wires[bitNum+1].append(cout_bit)
				wire_num += 1
	outer_wire_index += 1
	num += 1

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

f.write("// Adding using two CLA adders\n\n")

# define cla adders and add operandA and operandB
f.write("wire [31:0] lsb_data_operandA, lsb_data_operandB;\n")
f.write("wire lsb_cout;\n\n")

for i in range(31, -1, -1):
	f.write("assign lsb_data_operandA["+str(i)+"] = "+operandA[i]+";\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

for i in range(31, -1, -1):
	f.write("assign lsb_data_operandB["+str(i)+"] = "+operandB[i]+";\n")

f.write("wire [31:0] temp_result;\n")

f.write("cla_32 lsb_cla(temp_result, lsb_cout, lsb_data_operandA, lsb_data_operandB, 1'b0);\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

f.write("wire [31:0] msb_data_operandA, msb_data_operandB, msb_data_result;\n")
f.write("wire msb_cout;\n\n")

for i in range(31, -1, -1):
	f.write("assign msb_data_operandA["+str(i)+"] = "+operandA[i+32]+";\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

for i in range(31, -1, -1):
	f.write("assign msb_data_operandB["+str(i)+"] = "+operandB[i+32]+";\n")

f.write("cla_32 msb_cla(msb_data_result, msb_cout, msb_data_operandA, msb_data_operandB, lsb_cout);\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

f.write("// Check for overflow by checking whether all msb 32 bits are zero, or answer should be positive but leading bit is a 1\n")

f.write("wire or_result, is_positive, ovf, temp_data_exception;\n")

# f.write("or or_overflow(or_result, ")

# for i in range(31, 0, -1):
# 	f.write("msb_data_result["+str(i)+"], ")
# f.write("msb_data_result["+str(0)+"]);\n\n")

f.write("assign or_result = msb_data_result || {32{1'b0}} ? 1'b1 : 1'b0;\n")

f.write("xnor isPositive(is_positive, latched_data_A[31], latched_data_B[31]);\n\n")

f.write("and ovf_and(ovf, is_positive, temp_result[31]);\n")

f.write("or exception(temp_data_exception, ovf, or_result);\n")

f.write("dffe_ref dff(data_exception, temp_data_exception, clock, three_count, tff_reset);\n\n")

# separator
f.write("// ")
for i in range(60):
	f.write("-")
f.write("\n\n")

f.write("// flip back if xor(latched_data_A[31], latched_data_B[31]) == 1\n")

f.write("wire [31:0] flipped_result, temp_data_result;\n")
f.write("wire flipped_cout;\n\n")

f.write("cla_32 cla_flip(flipped_result, flipped_cout, ~temp_result, {32{1\'b0}}, 1'b1);\n\n")

f.write("wire xor_result;\n")

f.write("xor xor_flipped(xor_result, latched_data_A[31], latched_data_B[31]);\n\n")

f.write("assign temp_data_result = xor_result ? flipped_result : temp_result;\n")

f.write("register32 reg_data_result(data_result, temp_data_result, three_count, tff_reset, clock);\n")

f.write("endmodule")






