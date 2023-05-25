# Test Subject: UART comm
.text:
	li $s0, 0xffff0000
loop:
	lw $t1, 0xc($s0)
	lw $t2, 0x10($s0)
	sll $t1, $t1, 8
	or $t1, $t1, $t2
	sw $t1, 0x38($s0)
	j loop