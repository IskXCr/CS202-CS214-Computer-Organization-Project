# Test Subject: The scenario_2
.data 
    push_count: .word 0
    pop_count: .word 0
    stack_top: .word 0
    stack_size: .word 0
.text
.global main

main:

    beq $t0, 0, test_000
    beq $t0, 1, test_001
    beq $t0, 2, test_010
    beq $t0, 3, test_011
    beq $t0, 4, test_100
    beq $t0, 5, test_101
    beq $t0, 6, test_110
    beq $t0, 7, test_111

test_000:
    li $t0, 43
    li $t1, 0
    li $t2, 0
    # if the input is negative
    bgez $t0, loop
loop_light:    
    li $t2, 1
    li $t2, 0
    j loop_light
    # j end_program
loop:
    addi $t1, $t1, 1
    add $t2, $t2, $t1
    bne $t1, $t0, loop
    # t2 should be 946 = 3B2



test_001:
    li $t0, 43 # value of a 
    li $t2, 0
    li $t3, 0
    li $t4, 0
    jal sum
    # t2 should be 946 = 3B2
    add $t3, $t4, $t5 # the total number of the times
    # t3 should be 86
    j test_010
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
    li $t0, 43
    addi $a0, $t0, 0
    jal sum
    la $t1, stack_top 
    lw $t2, stack_size
loop_1:
    beq $t2, $zero, end_loop
    addi $t1, $t1, -4 
    lw $t3, 0($t1)
    li $t4, 3
loop_2:
    addi $t4, $t4, -1
    bne $t4, $zero, loop_2
    j loop_1
end_loop:
    
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
    li $t0, 43
    addi $a0, $t0, 0
    jal sum_1
    la $t1, stack_top 
    lw $t2, stack_size
loop_01:
    beq $t2, $zero, test_100
    addi $t1, $t1, -4 
    lw $t3, 0($t1)
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
    li $t0, 43
    addi $t2, $t0, 0
    li $t1, 43
    addi $t3, $t0, 0
    add $t4, $t2, $t3 # sum

    sltiu $t5, $t4, 256
    beq $t5, $zero, no_carry
    li $t6, 1 # carry
    j end_addition
no_carry:    
    li $t6, 0
end_addition:
    # sw $t4, 0x24($28)
    # sw $t4, 0x2C($28)
    # sw $t6, 0x20($28)

    # j end_program

test_101:
    # lw $t0, 0x0C($28)
    li $t0, 57
    addi $t2, $t0, 0
    # lw $t1, 0x0C($28)
    li $t0, 68
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
    # sw $t4, 0x24($28)
    # sw $t4, 0x2C($28)
    # sw $t5, 0x20($28)
    # j end_program

test_110:
    # lw $t0, 0x0C($28)
    li $t0, 9
    addi $t2, $t0, 0
    # lw $t1, 0x0C($28)
    li $t0, 10
    addi $t3, $t0, 0

    mult $t2, $t3 
    mfhi $t4 
    mflo $t5

    # sw $t5, 0x24($28)
    # sw $t5, 0x2C($28)

test_111:
    # lw $t0, 0x0C($28)
    li $t0, 35
    addi $t2, $t0, 0
    # lw $t1, 0x0C($28)
    li $t0, 7
    addi $t3, $t0, 0
    div $t2, $t3 
    mfhi $t5 
    mflo $t4 

loop_show:
    # sw $t4, 0x24($28)
    # sw $t4, 0x2C($28)
    li $t6, 5
loop_delay:
    subi $t5, $t5, 1
    neq $t5, $zero, loop_delay
    sw $t5, 0x24($28)
    sw $t5, 0x2C($28)
    j loop_show

end_program:
    j end_program
