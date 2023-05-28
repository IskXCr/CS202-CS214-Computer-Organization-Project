.text
################################
# Decode byte stream
# Total instruction count: 
################################	
	
################################
# Draw VGA buffer
# Total instruction count: 
################################
func_draw_vga_buf:
	# fill vga buffer, given a starting buffer address
	# $a0 the starting address of the frame buffer, 40x16 theoretically
	# $a1 the current frame count
	addi $sp, $sp, -4
	sw $gp, ($sp)
	li $gp, 0xffff0100
	
	# display frame info
	li $t0, 0x4d415246
	sw $t0, ($gp)
	li $t0, 0x20203a45
	sw $t0, 0x04($gp)
	
	# display frame number in hex
	addi $t0, $a0, 0x30303030
	andi $t1, $t0, 0xff000000
	srl $t1, $t1, 24
	andi $t2, $t0, 0x00ff0000
	srl $t2, $t2, 16
	andi $t3, $t0, 0x0000ff00
	srl $t3, $t3, 8
	andi $t0, $t0, 0x000000ff
	or $t0, $t0, $t1
	or $t0, $t0, $t2
	or $t0, $t0, $t3
	sw $t0, 0x08($gp)
	
	# fill the frame in the center of the screen
	# area starts at (20, 7); boundary at (59, 22)
	addi $gp, $gp, 485
	li $t2, 0
	li $t3, 16
func_draw_vga_buf_loop1:
	li $t0, 0
	li $t1, 10
func_draw_vga_buf_loop2:
	lw $t4, ($a0)
	sll $t5, $t0, 2
	addi $t5, $t5, $gp
	sw $t4, ($t5)
	addi $t0, $t0, 1
	bne $t0, $t1, func_draw_vga_buf_loop2
	addi $gp, $gp, 80
	addi $t2, $t2, 1
	bne $t2, $t3, func_draw_vga_buf_loop1
	
	addi $sp, $sp, 4
	jr $ra
	
	
################################
# Clear VGA buffer
# Total instruction count: NaN
################################
func_clear_vga_buf:
	addi $sp, $sp, -4
	sw $gp, ($sp)
	
	li $t2, 0
	li $t3, 30
func_clear_vga_buf_loop1:
	li $t0, 0
	li $t1, 20
func_clear_vga_buf_loop2:
	sll $t4, $t0, 2
	add $t4, $t4, $gp
	sw $zero, ($t4)
	addi $t0, $t0, 1
	bne $t0, $t1, func_clear_vga_buf_loop2
	addi $gp, $gp, 80
	addi $t2, $t2, 1
	bne $t2, $t3, func_clear_vga_buf_loop1

	addi $sp, $sp, 4
	jr $ra