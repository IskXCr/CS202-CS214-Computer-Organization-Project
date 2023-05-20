# Test Subject: Arithmetic and Logical Operations

.text
	move $t1, $zero
	addi $t1, $t1, 1
	# t1 should be 1
	addi $t2, $t1, 1
	addi $t2, $t2, 233
	subi $t2, $t2, 1
	# t2 should be 234.
	add $t3, $t2, $t1
	# t3 should be 235
	sub $t4, $t2, $t1
	# t4 should be 233
	sub $t5, $t1, $t2
	# t5 should be -233
	sll $t6, $t1, 3
	# t6 should be 8
	sllv $t7, $t6, $t1
	# t7 should be 16
	srl $s0, $t6, 3
	# s0 should be 1
	srlv $s1, $t6, $t1
	# s1 should be 4
	not $s2, $zero
	# s2 should be 0xffffffff
	srav $s3, $s2, $t1
	# s3 should be 0xffffffff
	sra $s4, $s2, 4
	# s4 should be 0x8fffffff
	
	sub $t4, $t2, $t1
end:
	j end