nop # Basic addi exception test with no Hazards
nop # Values initialized using addi (positive only)
nop # Author: Minjun Kwak
nop
nop
nop 
addi $r1, $r1, 32768
nop
nop
nop
sll $r1, $r1, 16
nop
nop
nop
addi $r2, $r1, -2 # overflow: $r2 should stay at 0 and $r30 should be 2