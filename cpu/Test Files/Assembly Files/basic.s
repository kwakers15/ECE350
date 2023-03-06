nop # Basic ALU / Memory Test with no Hazards
nop # Values initialized using addi (positive only)
nop # Author: Minjun Kwak
nop
nop
nop 
addi $r1, $r1, 10
addi $r2, $r2, 12
nop
nop
nop
nop
add $r4, $r1, $r2 # $r4 = 22
sub $r3, $r1, $r2 # $r3 = -2
addi $r9, $r9, 9
nop
nop
nop
and $r5, $r3, $r9 # $r5 has AND result = 8
addi $r22, $r22, 22
nop
nop
nop
or $r6, $r5, $r22 # $r6 has OR result = 30
nop
nop
nop
nop
sll $r7, $r6, 10 # $r7 has SLL result = 30720
nop
nop
nop
sra $r8, $r7, 11 # $r8 has SRA result = 15
nop
nop
nop
sw $r8, 10($r6)
lw $r10, 0($r6)
lw $r11, 10($r6) # $r11 has 15
setx 67108864