.eqv SLEEP_TIME_KEY 335200
.eqv SLEEP_TIME_DELTA 335200

.data
	sample_header: .word 0x00200261, 0x06610271, 0x0a680671, 0x0e680a71, 0x12680e71, 0x16661271, 0x1a611671, 0x1e611a71, 0x221f1e71, 0x22612257, 0x265a2271, 0x26712661, 0x2a582a4c, 0x2a712a61, 0x2e5c2e4c, 0x2e712e61, 0x0000327c
	sample_header2: .word 0x80000000, 0xccceeddf, 0x5216877b, 0x11115cc8, 0x11111111, 0x11111111, 0x00000000, 0x00000000, 0x11111170, 0x11111111, 0x11111111, 0x00000000, 0x00000000, 0x1111111e, 0x11111111, 0x11111111, 0x00000000, 0x00000000, 0x111177c0, 0x11116566, 0x11111111, 0x00000000, 0x00000000, 0x81110000, 0x60000000, 0x11111111, 0x00000000, 0x00000000, 0xc111f000, 0x00000000, 0x8111111e, 0x00000000, 0x00000000, 0x1111a000, 0x000000d8, 0x001111c0, 0x00000000, 0x00000000, 0x111111c0, 0x00000711, 0x00f1c000, 0x00000000, 0x00000000, 0x11111111, 0x0000f111, 0x00000000, 0x00000000, 0x00000000, 0x11111111, 0x00001111, 0x00000000, 0x00000000, 0x00000000, 0x1111111e, 0x00001111, 0x00000000, 0x00000000, 0x00000000, 0x11111400, 0x0000e111, 0x00000000, 0x00000000, 0x00000000, 0x115c0000, 0x000000e7, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
.text
.globl main
main:
	li $gp, 0xffff0000
	li $t0, 0x1
	sw $t0, 0x30($gp)
	jal func_clear_vga_buf
	li $t0, 0x2
	sw $t0, 0x30($gp)
	
	li $t0, 20000000
	li $t1, 0
main_loop:
	addi $t1, $t1, 1
	bne $t1, $t0, main_loop 
	li $t0, 0x3
	sw $t0, 0x34($gp)
	
	addi $sp, $sp, -636
	move $a0, $sp
	li $a1, 0x10010000
	jal func_parser
	addi $sp, $sp, 636
	j end_program

################################
# Parser
################################
func_parser:
	# parse the frame and draw it
	# $a0 the starting address of the frame buffer, 40x16
	# $a1 the starting address of the stream
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	li $s3, 0
	addi $sp, $sp, -64
	
	# build character mapping
	li $t0, 0x20
	sw $t0, 0x0($sp)
	li $t0, 0x4d
	sw $t0, 0x4($sp)
	li $t0, 0x40
	sw $t0, 0x8($sp)
	li $t0, 0x57
	sw $t0, 0xc($sp)
	li $t0, 0x30
	sw $t0, 0x10($sp)
	li $t0, 0x38
	sw $t0, 0x14($sp)
	li $t0, 0x5a
	sw $t0, 0x18($sp)
	li $t0, 0x61
	sw $t0, 0x1c($sp)
	li $t0, 0x32
	sw $t0, 0x20($sp)
	li $t0, 0x53
	sw $t0, 0x24($sp)
	li $t0, 0x37
	sw $t0, 0x28($sp)
	li $t0, 0x72
	sw $t0, 0x2c($sp)
	li $t0, 0x69
	sw $t0, 0x30($sp)
	li $t0, 0x3a
	sw $t0, 0x34($sp)
	li $t0, 0x3b
	sw $t0, 0x38($sp)
	li $t0, 0x2e
	sw $t0, 0x3c($sp)
	
	# $s0 frame buffer, $s1 stream buffer, $s2 frame count

func_parser_main_loop:
	# load header
	lw $t0, ($s1)
	addi $s1, $s1, 4
	bleu $t0, 0x7fffffff, func_parser_parse_delta
func_parser_parse_key:
	beq $t0, 0xffffffff, func_parser_end # if the last frame, pause
	# indicator
	li $t4, 1
	sw $t4, 0x30($gp)

	li $t0, 0      # offset
	li $t1, 80     # threshold
	move $t2, $s0  # current buffer write position
func_parser_parse_key_loop:
	
	lw $t3, ($s1) # generate in place
	addi $s1, $s1, 4
	# loop unrolling
	li $t4, 0
	
	# right 4 char
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 8
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 16
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 24
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	sw $t4, ($t2)
	addi $t2, $t2, 4
	
	# left four char
	li $t4, 0
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 8
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 16
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	andi $t5, $t3, 0x0000000f
	sll $t5, $t5, 2
	add $t5, $t5, $sp
	lw $t5, ($t5)
	sll $t5, $t5, 24
	or $t4, $t4, $t5
	srl $t3, $t3, 4
	
	sw $t4, ($t2)
	addi $t2, $t2, 4
	
	# loop end
	addi $t0, $t0, 1
	bne $t0, $t1, func_parser_parse_key_loop

	li $t0, 0
	li $t1, SLEEP_TIME_KEY
	sub $t1, $t1, 6128
func_parser_parse_key_delay:
	addi $t0, $t0, 1
	ble $t0, $t1, func_parser_parse_key_delay
	j func_parser_main_loop_end
	
func_parser_parse_delta:
	# indicator
	li $t4, 2
	sw $t4, 0x30($gp)
	# $t0 is the header. Everything else is usable
	# $s0 frame buffer address 
	# $s1 stream buffer address, modifiable
	# $s2 frame count
	
	# calculate size
	andi $t1, $t0, 0xffff0000
	srl $t1, $t1, 16
	beq $t1, $zero, func_parser_parse_delta_loop_end
	# $t1 the size of entries
	# get the first delta entry
	andi $t0, $t0, 0xffff
	jal func_parser_parse_delta_cont
	subi $t1, $t1, 1
	beq $t1, $zero, func_parser_parse_delta_loop_end
	sll $k1, $t1, 5
	
	li $t9, 0
	
func_parser_parse_delta_loop:
	lw $k0, ($s1)
	addi $s1, $s1, 4
	
	andi $t0, $k0, 0xffff
	jal func_parser_parse_delta_cont
	addi $t9, $t9, 1
	bge $t9, $t1 func_parser_parse_delta_loop_end
	
	andi $t0, $k0, 0xffff0000
	srl $t0, $t0, 16
	jal func_parser_parse_delta_cont
	addi $t9, $t9, 1
	bge $t9, $t1 func_parser_parse_delta_loop_end
	
	j func_parser_parse_delta_loop
	
func_parser_parse_delta_cont:
	andi $t2, $t0, 0xfc00
	srl $t2, $t2, 10
	andi $t3, $t0, 0x03f0
	srl $t3, $t3, 4
	andi $t4, $t0, 0x000f
	# $t2 y_pos
	# $t3 x_pos
	# $t4 character code
	sll $t6, $t2, 3
	sll $t7, $t2, 1
	add $t2, $t6, $t7 
	sll $t2, $t2, 2   # get $t2 * 40, the character offset
	add $t2, $t2, $s0 # position in the frame buffer
	andi $t5, $t3, 0xfffc # x_position offset
	add $t2, $t2, $t5 # $t2 the position of word of the character right now
	andi $t3, $t3, 0x0003 # $t3 now the offset of the character in the word
	sll $t4, $t4, 2
	add $t4, $t4, $sp
	lw $t4, ($t4)
	# $t4 now the entire character
	sll $t3, $t3, 3
	
	li $t5, 0xff
	sllv $t5, $t5, $t3
	not $t5, $t5
	lw $t6, ($t2)
	and $t6, $t6, $t5
	sllv $t4, $t4, $t3
	or $t6, $t6, $t4
	sw $t6, ($t2)
	# Completed parsing
	jr $ra
	
func_parser_parse_delta_loop_end:

	li $t0, 0
	li $t1, SLEEP_TIME_DELTA
	sub $t1, $t1, $k1
func_parser_parse_delta_delay:
	addi $t0, $t0, 1
	ble $t0, $t1, func_parser_parse_delta_delay
	
func_parser_main_loop_end:
	# call buffer filling
	move $a0, $s0
	move $a1, $s2
	jal func_draw_vga_buf
	beq $s2, 0xF, end_program #debug
	
	addi $s2, $s2, 1
	j func_parser_main_loop
	
func_parser_end:
	# indicator
	li $t4, 0xffff
	sw $t4, 0x30($gp)
	addi $sp, $sp, 64
	lw $ra, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 20
	jr $ra

end_program:
	j end_program	# end the program

################################
# Draw VGA buffer
# Total instruction count: 
################################
func_draw_vga_buf:
	# fill vga buffer, given a starting buffer address
	# $a0 the starting address of the frame buffer, 40x16 theoretically
	# $a1 the current frame count
	addi $sp, $sp, -4 # func_draw_vga_buf entry
	sw $gp, ($sp)
	li $gp, 0xffff0100
	
	# display frame info
	li $t0, 0x4d415246
	sw $t0, ($gp)
	li $t0, 0x20203a45
	sw $t0, 0x04($gp)
	
	# display frame number in hex
	move $t0, $a1
	li $t1, 0
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 func_draw_vga_buf_p1
	addi $t2, $t2, 0x7
func_draw_vga_buf_p1:
	sll $t2, $t2, 24
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 func_draw_vga_buf_p2
	addi $t2, $t2, 0x7
func_draw_vga_buf_p2:
	sll $t2, $t2, 16
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 func_draw_vga_buf_p3
	addi $t2, $t2, 0x7
func_draw_vga_buf_p3:
	sll $t2, $t2, 8
	or $t1, $t1, $t2
	srl $t0, $t0, 4
	
	andi $t2, $t0, 0x000f
	addi $t2, $t2, 0x30
	ble $t2, 0x39 func_draw_vga_buf_p4
	addi $t2, $t2, 0x7
func_draw_vga_buf_p4:
	or $t1, $t1, $t2
	
	sw $t1, 0x08($gp)
	
	# fill the frame in the center of the screen
	# area starts at (20, 7); boundary at (59, 22)
	addi $gp, $gp, 500
	li $t2, 0
	li $t3, 16
func_draw_vga_buf_loop1:
	li $t0, 0
	li $t1, 10
func_draw_vga_buf_loop2:
	lw $t4, ($a0)
	sw $t4, ($gp)
	addi $a0, $a0, 4
	addi $gp, $gp, 4
	addi $t0, $t0, 1
	bne $t0, $t1, func_draw_vga_buf_loop2
	addi $gp, $gp, 40
	addi $t2, $t2, 1
	bne $t2, $t3, func_draw_vga_buf_loop1
	
	lw $gp, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
################################
# Clear VGA buffer
# Total instruction count: NaN
################################
func_clear_vga_buf:
	addi $sp, $sp, -4
	sw $gp, ($sp)
	li $gp, 0xffff0100
	
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
	bne $t2, $t3, func_clear_vga_buf_loop1 # debug

	lw $gp, ($sp)
	addi $sp, $sp, 4
	jr $ra
