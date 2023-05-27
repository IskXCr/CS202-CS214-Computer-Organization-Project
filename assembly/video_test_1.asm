.data
	debug_message:  .ascii "Initiated video test on Address 0xffff_0100                                     "
	debug_message2: .ascii "Hello World!                                                                    "
.text
	li $s0, 0xffff0100
	li $t1, 80
	li $t0, 0
	la $t2, debug_message
jfill1:	
	add $t3, $t2, $t0
	add $t4, $s0, $t0
	lw $t5, 0($t3)
	sw $t5, 0($t4)
	addi $t0, $t0, 4
	bne $t0, $t1, jfill1
	
	li $s0, 0xffff0150
	li $t1, 80
	li $t0, 0
	la $t2, debug_message
jfill2:	
	add $t3, $t2, $t0
	add $t4, $s0, $t0
	lw $t5, 0($t3)
	sw $t5, 0($t4)
	addi $t0, $t0, 4
	bne $t0, $t1, jfill2
	
	li $s0, 0xffff01a0
	li $t0, 0
	la $t2, debug_message2
jfill3:	
	add $t3, $t2, $t0
	add $t4, $s0, $t0
	lw $t5, 0($t3)
	sw $t5, 0($t4)
	addi $t0, $t0, 4
	bne $t0, $t1, jfill3
	
	la $t2, debug_message
	
	li $s0, 0xffff0000
	lw $t3, 0($t2)
	andi $t4, $t3, 0xff00
	srl $t4, $t4, 8
	sw $t3, 0x30($s0)
	sw $t4, 0x34($s0)
end:
	j end
