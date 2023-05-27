# Test Subject: slt and sltu

.text
	li $t0, 1
	li $t1, 2
	slt $t3, $t0, $t1
	# t3 should be 1
	
	li $t0, -34
	li $t1, 78
	slt $t4, $t0, $t1
	# t4 should be 1
	sltu $t5, $t0, $t1
	# t5 should be 0
	li $t0, 78
	li $t1, -34
	slt $t6, $t0, $t1
	# t6 should be 0
	sltu $t7, $t0, $t1
	# t7 should be 1
	slti $s0, $t0, 79
	# s0=1
	sltiu $s1, $t0, -233
	# s1=1
	slti $s2, $t0, 77
	# s2=0
	slti $s3, $t1, 34
	# s3 = 1
	sltiu $s4, $t1, 34
	# s4 = 0 
end:
	j end