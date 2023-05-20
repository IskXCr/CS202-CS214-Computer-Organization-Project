# Test Subject: Branch and link instruction, with other stuff.
.text
	li $t0, 0
	li $s0, 16
	# s0 stays at 16
loop:
	addi $t0, $t0, 1
	bne $t0, $s0, loop
	# now t0 becomes 16

	li $t1, 1
	bgezal $t1, link_test
	li $t3, 233
	# now t2 and t3 becomes 233
	
	li $t4, 1
loop2:
	addi $t4, $t4, 1
	blt $t4, $s0, loop2
	# now t4 becomes 16
	
	li $t5, 0x7fecffff
	# t5 becomes 0x7fecffff
	
	li $t6, -3
	bltz $t6, bltz_test
	j bltz_end
	# now t6 becomes -3
bltz_test:
	li $t7, 233
bltz_end:
	li $s0, 233
	# now t7 and s0 becomes 233
end:
	j end

link_test:
	li $t2, 233
	jr $ra
	