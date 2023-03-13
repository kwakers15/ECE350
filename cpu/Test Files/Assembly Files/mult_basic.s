nop # Basic mult test with no Hazards
nop # Values initialized using addi (positive only)
nop # Author: Minjun Kwak
nop
nop
nop 
addi $r1, $r0, 10
addi $r2, $r0, 12
nop
nop
mul $r3, $r1, $r2 # r3 should contain 120
addi $r4, $r3, 4
mul $r5, $r3, $r1 # r5 should contain 1200