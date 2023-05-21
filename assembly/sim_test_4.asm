# Test Subject: Interrupt Call and Stack Frame Pointer

.text 0x00400000
hi:
	addi $t0, $zero, 2
	teq $zero, $zero
	li $v0, 10
	syscall

.text 0x80000180
interrupt_handler:
	addi $t0, $t0, 1
	mfc0 $t1, $14
	addi $t1, $t1, 4
	mtc0 $t1, $14
	eret