# Test Subject: Accumulation and stack frame pointer

.text
	li $t0, 6666
	li $t1, 2333
	mult $t0, $t1
	mfhi $t2
	mflo $t3
	div $t0, $t1
	mfhi $t4
	mflo $t5
	mthi $t0
	mtlo $t1
	li $gp, 0xffff0000
	sw $t3, 0x30($gp)
	sw $t4, 0x34($gp)
end:
	j end