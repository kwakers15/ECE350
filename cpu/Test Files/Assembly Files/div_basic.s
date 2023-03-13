nop # Basic div test with no Hazards
nop # Values initialized using addi (positive only)
nop # Author: Minjun Kwak
nop
nop
nop 
addi $r1, $r0, 100
addi $r2, $r0, 12
nop
nop
div $r3, $r1, $r2 # r3 should contain 8
addi $r4, $r3, 4
mul $r5, $r3, $r1 # r5 should contain 800
div $r6, $r5, $r4 # r6 should contain 66