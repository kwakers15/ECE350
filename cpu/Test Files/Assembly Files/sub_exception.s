nop # Basic sub exception test with no Hazards
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
addi $r2, $r2, 65535
nop
nop
nop
sll $r2, $r2, 15
nop
nop
nop
addi $r2, $r2, 32767
nop
nop
nop
sub $r3, $r1, $r2 # overflow: 1 normally, but $r3 should stay at 0 and $r30 should be 1