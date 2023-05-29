# Test Subject: Keypad Value -> VGA

.text
	li $gp, 0xffff0000
	lw $t0, 0x14($gp)
	li $t1, 0
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 io_test_jmp_p1
	addi $t2, $t2, 0x7
io_test_jmp_p1:
	sll $t2, $t2, 24
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 io_test_jmp_p2
	addi $t2, $t2, 0x7
io_test_jmp_p2:
	sll $t2, $t2, 16
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 io_test_jmp_p3
	addi $t2, $t2, 0x7
io_test_jmp_p3:
	sll $t2, $t2, 8
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 io_test_jmp_p4
	addi $t2, $t2, 0x7
io_test_jmp_p4:
	or $t1, $t1, $t2

	# Now value is in $t1
	sw $t1, 0x176($gp)

end:
	j end