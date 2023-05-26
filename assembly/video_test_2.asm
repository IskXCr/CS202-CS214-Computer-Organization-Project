.text
	li $s0, 0xffff0100
	li $s1, 0
	li $t0, 0
	li $t1, 30
jloop1:
	li $t2, 0
	li $t3, 80
jloop2:
	sw $s1, ($s0)
	addi $s1, $s1, 1
	addi $s0, $s0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, jloop2
	addi $t0, $t0, 1
	bne $t0, $t1, jloop1
	
	li $s0, 0xffff0000
	li $t3, 0x12AC
	andi $t4, $t3, 0xff00
	srl $t4, $t4, 8
	sw $t3, 0x30($s0)
	sw $t4, 0x34($s0)
end:
	j end