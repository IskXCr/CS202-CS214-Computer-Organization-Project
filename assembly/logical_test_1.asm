# Test Subject: Accumulation and stack frame pointer

.text
	li $s0, 0xffff0000
	lw $t0, 0x0c($s0)
	li $t1, 0
	li $t2, 0
loop:
	add $t2, $t2, $t1
	addi $t1, $t1, 1
	ble $t1, $t0, loop
	sw $t2, 0x34($s0)
	
	li $t0, 3
	sw $t0, ($sp)
	li $t0, 7
	sw $t0, -4($sp)
	lw $t0, ($sp)
	add $t2, $t0, $zero
	lw $t0, -4($sp)
	add $t2, $t2, $t0
	sw $t2, 0x38($s0)
	
	jal func
	sw $v0, 0x30($s0)
end:
	j end
	
func:
	li $v0, 0xAB
	jr $ra