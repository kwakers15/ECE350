nop
nop
nop
nop
nop
addi $r1, $r1, 1
addi $r5, $r5, 5
addi $r6, $r6, 6
addi $r8, $r8, 23
addi $r11, $r11, 15
nop
bne $r5, $r6, _after_branch
addi $r9, $r9, 9
addi $r12, $r12, 12
addi $r16, $r16, 16
_after_branch:
addi $r11, $r11, 8
addi $r20, $r20, 20
nop
nop
bne $r11, $r8, _end
addi $r13, $r13, 13
_end:
addi $r14, $r14, 14
blt $r20, $r11, _after_branch
addi $r30, $r30, 4
nop
nop
_decrement_rstatus:
sub $r30, $r30, $r1
addi $r7, $r7, 7
nop
bex _loop 
j _jump_dest
_loop:
addi $r2, $r2, 2
addi $r4, $r4, 4
j _decrement_rstatus
_jump_dest:
addi $r3, $r3, 3
jal _jump_link
addi $r23, $r23, 23
j _real_end

_jump_link:
addi $r21, $r21, 21
addi $r22, $r22, 22
addi $r23, $r23, 23
jr $r31

_real_end:
addi $r24, $r24, 24