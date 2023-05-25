# Test Subject: 7-seg tube MMIO and CPU status
.data 
	reg1: .word 0x3377
	reg2: .word 0xcccc
	
.text
	lw $t1, reg1
	addi $t1, $t1, 1
	# t1 should be 0x3378
	sw $t1, reg1
	lw $t2, reg1
	# t2 should be 0x3378
	li $s0, 0xffff0000
	sw $t1, 0x30($s0)
	sw $t2, 0x34($s0)
end:
	j end
