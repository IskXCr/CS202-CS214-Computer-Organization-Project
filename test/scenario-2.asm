.data 
    push_count: .word 0
    pop_count: .word 0
    stack_top: .word 0
    stack_size: .word 0
.text
.global main

main:

    lui $28, 0x1000
    ori $28, $28, 0x0000

    # 0xC60($28) LED
    # 0xC9C($28) segtube
    lw $t0, 0xC78($28)
    andi $t0, $t0, 0x07 # get the lower 3 bits    

    beq $t0, 0, test_000
    beq $t0, 1, test_001
    beq $t0, 2, test_010
    beq $t0, 3, test_011
    beq $t0, 4, test_100
    beq $t0, 5, test_101
    beq $t0, 6, test_110
    beq $t0, 7, test_111

test_000:
    lw $t0, 0xC70($28)
    li $t1, 0
    li $t2, 0
    # if the input is negative
    bgez $t0, loop
loop_light:    
    li $t2, 1
    sw $t2, 0xC60($28)
    li $t2, 0
    sw $t2, 0xC60($28)
    j loop_light
    # j end_program
loop:
    addi $t1, $t1, 1
    add $t2, $t2, $t1
    bne $t1, $t0, loop
    sw $t2, 0xC60($28) # LED output
    sw $t2, 0xC9C($28) # seg output
    

    j end_program


test_001:
    lw $t0, 0xC70($28) # value of a 
    li $t2, 0
    li $t3, 0
    li $t4, 0
    jal sum
    sw $t2, 0xC60($28) # the sum
    sw $t2, 0xC9C($28)
    add $t3, $t4, $t5 # the total number of the times
    sw $t3, 0xC60($28)
    sw $t3, 0xC9C($28)
    j end_program
sum_recursive: 
    addi $sp, $sp, -8 
    sw $ra, 4($sp) 
    sw $t2, 0($sp) 
    beq $t0, $zero, end_recursive 
    add $t2, $t2, $t0 
    addi $t4, $t4, 1 # the count of in_stack
    addi $t0, $t0, -1 
    jal sum_recursive 
    addi $t5, $t5, 1  # the count of out_stack
    lw $t2, 0($sp) 
    lw $ra, 4($sp) 
    addi $sp, $sp, 8 
    jr $ra 
end_recursive: 
    jr $ra


test_010:
    lw $t0, 0xC70($28)
    addi $a0, $t0, 0
    jal sum
    la $t1, stack_top 
    lw $t2, stack_size
loop_1:
    beq $t2, $zero, end_loop
    addi $t1, $t1, -4 
    lw $t3, 0($t1)
    sw $t3, 0xC60($28)
    li $t4, 3
loop_2:
    addi $t4, $t4, -1
    bne $t4, $zero, loop_2
    j loop_1
end_loop:
    j end_program
    
sum: 
    addi $sp, $sp, -8 
    sw $ra, 4($sp) 
    sw $a0, 0($sp) 
    sw $a1, 8($sp) 
    beq $a0, $zero, end_recursive 
    addi $a1, $a1, 1 
    add $t0, $a0, -1 
    sw $t0, 0($sp) 
    addi $t1, $t1, -4 
    sw $a0, 0($t1) 
    addi $t2, $t2, 1 
    sw $t2, stack_size 
    jal sum 
    lw $a1, 8($sp) 
    lw $a0, 0($sp) 
    addi $t1, $t1, 4 
    lw $t0, 0($t1) 
    add $a0, $t0, $a0 
    addi $t2, $t2, -1 
    lw $t2, stack_size 
    lw $ra, 4($sp) 
    addi $sp, $sp, 8 
    jr $ra 


test_011:
    lw $t0, 0xC70($28)
    addi $a0, $t0, 0
    jal sum_1
    la $t1, stack_top 
    lw $t2, stack_size
loop_01:
    beq $t2, $zero, end_loop
    addi $t1, $t1, -4 
    lw $t3, 0($t1)
    sw $t3, 0xC60($28)
    li $t4, 3
loop_02:
    addi $t4, $t4, -1
    bne $t4, $zero, loop_02
    j loop_01
    
sum_1: 
    addi $sp, $sp, -8 
    sw $ra, 4($sp) 
    sw $a0, 0($sp) 
    sw $a1, 8($sp) 
    beq $a0, $zero, end_recursive 
    addi $a1, $a1, 1 
    add $t0, $a0, -1 
    sw $t0, 0($sp) 
    addi $t1, $t1, -4 
    addi $t2, $t2, 1 
    sw $t2, stack_size 
    jal sum_1 
    lw $a1, 8($sp) 
    lw $a0, 0($sp) 
    sw $a0, 0($t1) 
    addi $t1, $t1, 4 
    lw $t0, 0($t1) 
    add $a0, $t0, $a0 
    addi $t2, $t2, -1 
    lw $t2, stack_size 
    lw $ra, 4($sp) 
    addi $sp, $sp, 8 
    jr $ra 


test_100:
    lw $t0, 0xC70($28)
    addi $t2, $t0, 0
    lw $t1, 0xC70($28)
    addi $t3, $t0, 0
    add $t4, $t2, $t3 # sum

    sltiu $t5, $t4, 256
    beq $t5, $zero, no_carry
    li $t6, 1 # carry
    j end_addition
no_carry:    
    li $t6, 0
end_addition:
    sw $t4, 0xC60($28)
    sw $t6, 0xC60($28)

    j end_program

test_101:
    lw $t0, 0xC70($28)
    addi $t2, $t0, 0
    lw $t1, 0xC70($28)
    addi $t3, $t0, 0
    
    sub $t4, $t2, $t3

    bltz $t4, overflow
    bgez $t4, no_overflow

overflow:
    li $t5, 1
    j end_subtraction
no_overflow:
    li $t5, 0
end_subtraction:
    sw $t4, 0xC60($28)
    sw $t5, 0xC60($28)
    j end_program

test_110:
    lw $t0, 0xC70($28)
    addi $t2, $t0, 0
    lw $t1, 0xC70($28)
    addi $t3, $t0, 0

    mult $t2, $t3 
    mfhi $t4 
    mflo $t5
    sw $t5, 0xC60($28)

test_111:
    lw $t0, 0xC70($28)
    addi $t2, $t0, 0
    lw $t1, 0xC70($28)
    addi $t3, $t0, 0
    div $t2, $t3 
    mfhi $t5 
    mflo $t4 

    sw $t4, 0xC60($28)
    sw $t5, 0xC60($28)

end_program:
    j end_program
