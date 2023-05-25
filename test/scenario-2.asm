.data 
    push_count: .word 0
    pop_count: .word 0
    stack_top: .word 0
    stack_size: .word 0
.text
.global main

main:
    # $28 0xffff0000
    lui $28, 0xffff
    ori $28, $28, 0x0000
    # testcase number
    lw $t0, 0x08($28)
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
    # sw[15:8] t0 - a
    lw $t0, 0x0C($28)
    jal signed_extension
    li $t1, 0 
    li $t2, 0
    # if the input is negative
    bgez $t0, loop
loop_light:    
    # LED[16] bling
    li $t2, 1
    sw $t2, 0x2C($28)
    li $t2, 0
    sw $t2, 0x2C($28)
    j loop_light
loop:
    # $t2 - sum   $t1 from 1 to $t0
    addi $t1, $t1, 1
    add $t2, $t2, $t1
    bne $t1, $t0, loop
    sw $t2, 0x38($28) # LED output
    sw $t2, 0x34($28) # seg output RIGHT
    
    j end_program



test_001:
    lw $t0, 0x0C($28) # value of a
    li $t2, 0  # the sum
    li $t3, 0  # number of push and pop
    jal sum
    # sw $t2, 0x2C($28) # the sum
    # sw $t2, 0x24($28)
    sw $t3, 0x38($28) # LED Tube RIGHT 
    sw $t3, 0x34($28) # LED[15:0]
    j end_program
sum_recursive: 
    addi $sp, $sp, -8 
    sw $ra, 4($sp) 
    sw $t0, 0($sp)
    addi $t3, $t3, 2 # count the pop and push number
    slti $t4, $t0, 1
    beq $t4, $zero, Base_case1
    addi $sp, $sp, 8
    jr $ra
Base_case1:
    addi $t0, $t0, -1
    jal sum_recursive
    lw $t0, 0($sp)
    lw $ra, 4($sp)
    addi $t3, $t3, 2
    addi $sp, $sp, 8
    add $t2, $t2, $t0
    jr $ra


test_010:
    lw $t0, 0x0C($28)
    addi $a0, $t0, 0
    jal sum
    j end_program
sum:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    sw $a0, 0x38($28)
    sw $a0, 0x34($28)
    sll $zero, $zero, 2 # print and stop for 2s
    slti $t0, $a0, 1
    beq $t0, $zero, Base_case2 
    addi $sp, $sp, 8
    jr $ra
Base_case2:
    addi $a0, $a0, -1
    jal sum_1
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra



test_011:
    lw $t0, 0x0C($28)
    addi $a0, $t0, 0
    jal sum_1
    j end_program
sum_1:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)
    slti $t0, $a0, 1
    beq $t0, $zero, Base_case3 
    addi $sp, $sp, 8
    jr $ra
Base_case3:
    addi $a0, $a0, -1
    jal sum_1
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    sw $a0, 0x38($28)
    sw $a0, 0x34($28)
    sll $zero, $zero, 2 # stop for 2s
    addi $sp, $sp, 8
    jr $ra

test_100:
    lw $t0, 0x0C($28)
    jal signed_extension
    addi $t2, $t0, 0 # a 
    lw $t0, 0x10($28)
    jal signed_extension
    addi $t3, $t0, 0 # b
    add $t4, $t2, $t3 # sum 
    # t5, t6, t7- signed of a, b, a + b
    slt $t5, $t2, $zero
    slt $t6, $t3, $zero
    slt $t7, $t4, $zero
    li $s0, 0 # overflow
    bne $t5, $t6, end_addition
    beq $t6, $t7, end_addition
    li $s0, 1 # carry
end_addition:
    sw $t4, 0x38($28)
    sw $t4, 0x34($28) 
    sw $s0, 0x2c($28) # LED[16]

    j end_program


test_101:
    lw $t0, 0x0C($28)
    jal signed_extension
    addi $t2, $t0, 0 # a
    lw $t0, 0x10($28)
    jal signed_extension
    addi $t3, $t0, 0 # b
    sub $t4, $t2, $t3
    # t5, t6, t7- signed of a, b, a - b
    slt $t5, $t2, $zero
    slt $t6, $t3, $zero
    slt $t7, $t4, $zero
    li $s0, 0 # overflow
    bne $t5, $t6, end_subtraction
    beq $t6, $t7, end_subtraction
    li $s0, 1 # carry
end_subtraction:
    sw $t4, 0x38($28)
    sw $t4, 0x34($28) 
    sw $s0, 0x2c($28) # LED[16]
    j end_program



test_110:
    lw $t0, 0x0C($28)
    jal signed_extension
    addi $t2, $t0, 0 # a
    lw $t0, 0x10($28)
    jal signed_extension
    addi $t3, $t0, 0 # b

    mult $t2, $t3 
    mflo $t4
    sw $t4, 0x34($28)
    sw $t4, 0x38($28)

test_111:
    lw $t0, 0x0C($28)
    jal signed_extension
    addi $t2, $t0, 0 # a
    lw $t0, 0x10($28)
    jal signed_extension
    addi $t3, $t0, 0 # b

    div $t2, $t3 
    mflo $t4 # quotient
    mult $t3, $t4
    mflo $t3
    sub $t2, $t2, $t3 # remainder
    li $t5, 0
Test_111_loop:
    addi $t5, $t5, 1
    addi $t6, $t4, 0
    andi $t7, $t5, 1
    beq $t7, 1, Test_111_loop2
    addi $t6, $t2, 0
Test_111_loop2:
    sw $t6, 0x38($28)
    beq $t5, 100, end_program
    j Test_111_loop

end_program:
    j end_program

signed_extension:
    slti $t1, $t0, 128
    sll $zero, $zero, 5 # delay for 5 seconds
    beq $t1, 0, end_signed_extension
    or $t0, $t0, 65280
end_signed_extension:
    jr $ra