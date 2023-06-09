.data 
    push_count: .word 0
    pop_count: .word 0
    stack_top: .word 0
    stack_size: .word 0
.text
.global main

main:
    # $28 0xffff0000
    li $28, 0xffff0000
    li $t0, -1
    sw $t0, 0x0c($28)
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
    sw $t0, 0x30($28)
    # jal signed_extension
    li $t1, 0 
    li $t2, 0
    # if the input is negative
    slt $t3, $t0, $zero
    beq $t3, 1, loop_light
    j loop
loop_light:    
    # LED[16] bling
    li $t2, 1
    sw $t2, 0x2C($28)
    li $26, 0x4C4B40
    li $27, 0
loop_delay0:
    addi $27, $27, 1
    bne $27, $26, loop_delay0
    
    li $t2, 0
    sw $t2, 0x2C($28)
    
    li $27, 0
loop_delay_tlbc3a:
    addi $27, $27, 1
    bne $27, $26, loop_delay_tlbc3a
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
    jal sum_recursive
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
    li $26, 0x4C4B40
    li $27, 0
loop_delay2: # print and stop for 2s
    addi $27, $27, 1
    bne $27, $26, loop_delay2
    # sll $zero, $zero, 2 # print and stop for 2s
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
    li $26, 0x4C4B40
    li $27, 0
loop_delay3: # print and stop for 2s
    addi $27, $27, 1
    bne $27, $26, loop_delay3
    addi $sp, $sp, 8
    jr $ra

test_100:
    lw $t0, 0x0C($28)
    # jal signed_extension
    addi $t2, $t0, 0 # a 
    lw $t0, 0x10($28)
    addi $t3, $t0, 0 # b
    add $t4, $t2, $t3 # sum 
    # t5, t6, t7- signed of a, b, a + b
    sltiu $t5, $t2, 128
    sltiu $t6, $t3, 128
    sltiu $t7, $t4, 128
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
    # jal signed_extension
    addi $t2, $t0, 0 # a
    lw $t0, 0x10($28)
    # jal signed_extension
    addi $t3, $t0, 0 # b
    sub $t4, $t2, $t3
    # t5, t6, t7- signed of a, b, a - b
    sltiu $t5, $t2, 128
    sltiu $t6, $t3, 128
    sltiu $t7, $t4, 128
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
    # jal signed_extension
    addi $t2, $t0, 0 # a
    sw $t2, 0x30($28)
    lw $t0, 0x10($28)
    addi $t3, $t0, 0 # b
    sw $t3, 0x34($28)
    sltiu $t5, $t2, 128
    beq $t5, 1, positive_a
    # subu $t2, $zero, $t2
    # addu $t2, $t2, 256
    # ori $t2, $t2, 0xffffff00
    not $t2, $t2
    # xori $t2, $t2, 0xff
    addi $t2, $t2, 1
positive_a:
    sltiu $t6, $t3, 128
    beq $t6, 1, positive_b
    # ori $t3, $t3, 0xffffff00
    not $t3, $t3
    # xori $t3, $t3, 0xff
    addi $t3, $t3, 1
    # subu $t3, $zero, $t3
    # addu $t3, $t3, 256
positive_b:
    xor $t5, $t5, $t6
    li $t4, 0
    li $a0, 0
    li $a1, 8
loop_mul:
    li $s1, 1
    and $s2, $s1, $t3
    beq $s2, $0, jumpAdd
    add $t4, $t2, $t4
jumpAdd:
    sll $t2, $t2, 1
    srl $t3, $t3, 1
    addi $a0, $a0, 1
    blt $a0, $a1, loop_mul
    beq $t5, 0, positive
    not $t4, $t4
    addi $t4, $t4, 1
positive:
    sw $t5, 0x2c($28) # show if the result is negative or not
    sw $t4, 0x34($28)
    sw $t4, 0x38($28)
    j end_program

test_111:
    lw $t0, 0x0C($28) 
    # jal signed_extension
    addi $t1, $t0, 0 # a 
    sltiu $t5, $t1, 128
    sw $t5, 0x20($28)
    beq $t5, 1, positive_div_a
    # subu $t1, $zero, $t1
    # addu $t1, $t1, 256
    #nop
    not $t1, $t1
    # nop
    # xori $t1, $t1, 0xff
    addi $t1, $t1, 1

positive_div_a:
    lw $t0, 0x10($28)
    # jal signed_extension
    addi $t2, $t0, 0 # b
    sltiu $t6, $t2, 128
    beq $t6, 1, positive_div_b 
    # subu $t2, $zero, $t2
    # addu $t2, $t2, 256
    # ori $t2, $t2, 0xffffff00
    # nop
    not $t2, $t2
    # nop
    # xori $t2, $t2, 0xff
    addi $t2, $t2, 1
positive_div_b:
    # sw $t1, 0x30($28)
    # sw $t2, 0x34($28)
    xor $t7, $t6, $t5 #check the sign
    sll $t2, $t2, 8
    addi $t3, $t1, 0 #t3 remainder
    li $t4, 0 #t4 quot
    li $t0, 0
    li $v0, 9
    li $a0, 0x1000
loopb:
# $t1: dividend, $t2: divisor, $t3: remainder, $t4: quot
    subu $t3,$t3,$t2 #dividend - dividor
    and $s0,$t3,$a0 # get the higest bit of rem to check if rem<0
    sll $t4,$t4,1 # shift left quot with 1bit
    beq $s0,$0, SdrUq # if rem>=0, shift Div right
    add $t3,$t3,$t2 # if rem<0, rem=rem+div
    srl $t2,$t2,1
    addi $t4,$t4,0
    j loope
    SdrUq:
    srl $t2,$t2,1
    addi $t4,$t4,1
    loope:
    addi $t0,$t0,1
    bne $t0,$v0,loopb
    beq $t7, 0, positive_quot
    not $t4, $t4
    addi $t4, $t4, 1 
positive_quot:
    beq $t5, 1, positive_rem
    not $t3, $t3
    addi $t3, $t3, 1    
positive_rem:
    li $t5, 0
    sw $t3, 0x30($28)
    sw $t4, 0x34($28)
Test_111_loop:
    addi $t5, $t5, 1
    addi $t6, $t3, 0
    andi $t7, $t5, 1
    beq $t7, 1, Test_111_loop2
    addi $t6, $t4, 0
Test_111_loop2:
    sw $t6, 0x38($28)
    li $26, 0x8C4B40
    li $27, 0
loop_delay4: # print and stop for 2s
    addi $27, $27, 1
    bne $27, $26, loop_delay4
    beq $t5, 100, end_program
    j Test_111_loop

end_program:
    j end_program

signed_extension:
    slti $t1, $t0, 128
    beq $t1, 0, end_signed_extension
    or $t0, $t0, 65280
end_signed_extension:
    jr $ra