nop # Basic add exception test with no Hazards
nop # Values initialized using addi (positive only)
nop # Author: Minjun Kwak
nop
nop
nop 
addi $r1, $r1, 32768
nop
nop
nop
sll $r1, $r1, 15
addi $r2, $r2, 32768
nop
nop
nop
sll $r2, $r2, 15
nop
nop
nop
add $r3, $r1, $r2 # overflow: -2147483648 normally, but $r3 should stay at 0 and $r30 should be 1