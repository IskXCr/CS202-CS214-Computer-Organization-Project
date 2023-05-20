# Test Subject: Data Segment and Store/Write Operations
.data 
	reg1: .word 0x8888
	reg2: .word 0xcccc
	
.text
	lw $t1, reg1
	addi $t1, $t1, 1
	# t1 should be 0x8889
	sw $t1, reg1
	lw $t2, reg1
	# t2 should be 0x8889
	lw $t3, reg2
	# t3 should be 0xcccc
end:
	j end